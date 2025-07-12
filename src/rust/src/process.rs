use extendr_api::prelude::*;

pub enum Column {
    Boolean(Vec<Option<bool>>),
    Number(Vec<Option<f64>>),
    FixedTimestamp(Vec<Option<f64>>),
    FloatingTimestamp(Vec<Option<f64>>),
    Text(Vec<Option<String>>),
    Url((Vec<Option<String>>, Vec<Option<String>>)),
    Photo(Vec<Option<String>>),
    Document(Vec<Option<String>>),
    Point(Vec<Option<(f64, f64)>>),
    Line(Vec<Option<Vec<(f64, f64)>>>),
    Polygon(Vec<Option<Vec<Vec<(f64, f64)>>>>),
    MultiPoint(Vec<Option<Vec<(f64, f64)>>>),
    MultiLine(Vec<Option<Vec<Vec<(f64, f64)>>>>),
    MultiPolygon(Vec<Option<Vec<Vec<Vec<(f64, f64)>>>>>),
    Location(
        (
            Vec<Option<(f64, f64)>>, // lat/lon pairs
            Vec<Option<String>>,     // addresses
            Vec<Option<String>>,     // cities
            Vec<Option<String>>,     // states
            Vec<Option<String>>,     // zips
        ),
    ),
}

/// Convert a vector of named columns into an R data.frame.
pub fn as_rlist(col_names: Vec<String>, columns: Vec<Column>) -> List {
    let robj_columns: Vec<Robj> = columns
        .into_iter()
        .map(|column| match column {
            Column::Boolean(values) => as_logical(values),
            Column::Number(values) => as_numeric(values),
            Column::FixedTimestamp(values) => as_posixct_utc(values),
            Column::FloatingTimestamp(values) => as_posixct_naive(values),
            Column::Text(values) => as_character(values),
            Column::Point(values) => as_point_sfc(values),
            Column::Url((urls, descs)) => as_url_list(urls, descs),
            Column::Photo(values) => as_character(values), //
            Column::Document(values) => as_character(values),
            Column::Line(values) => as_line_sfc(values),
            Column::Polygon(values) => as_polygon_sfc(values),
            Column::MultiPoint(vec) => as_multipoint_sfc(vec),
            Column::MultiLine(vec) => as_multiline_sfc(vec),
            Column::MultiPolygon(values) => as_multipolygon_sfc(values),
            Column::Location((coords, addresses, cities, states, zips)) => {
                as_location_list(coords, addresses, cities, states, zips)
            }
        })
        .collect();

    let rlist = List::from_names_and_values(col_names, robj_columns);

    rlist.unwrap()
}

fn as_logical(values: Vec<Option<bool>>) -> Robj {
    let vec: Vec<Rbool> = values
        .into_iter()
        .map(|opt| opt.map_or(Rbool::na(), Rbool::from))
        .collect();
    Robj::from(vec)
}

fn as_numeric(values: Vec<Option<f64>>) -> Robj {
    let vec: Vec<Rfloat> = values
        .into_iter()
        .map(|opt| opt.map_or(Rfloat::na(), Rfloat::from))
        .collect();
    Robj::from(vec)
}

fn as_posixct_utc(values: Vec<Option<f64>>) -> Robj {
    let vec: Vec<Rfloat> = values
        .into_iter()
        .map(|opt| opt.map_or(Rfloat::na(), Rfloat::from))
        .collect();

    let mut robj = r!(vec);
    robj.set_class(&["POSIXct", "POSIXt"]).unwrap();
    robj.set_attrib("tzone", "UTC").unwrap();
    robj
}

fn as_posixct_naive(values: Vec<Option<f64>>) -> Robj {
    let vec: Vec<Rfloat> = values
        .into_iter()
        .map(|opt| opt.map_or(Rfloat::na(), Rfloat::from))
        .collect();
    let mut robj = r!(vec);
    robj.set_class(&["POSIXct", "POSIXt"]).unwrap();
    robj.set_attrib("tzone", "").unwrap();
    robj
}

fn as_character(values: Vec<Option<String>>) -> Robj {
    let vec: Vec<Option<&str>> = values.iter().map(|opt| opt.as_deref()).collect();
    r!(vec)
}

fn as_url_list(urls: Vec<Option<String>>, descs: Vec<Option<String>>) -> Robj {
    let url = as_character(urls);
    let description = as_character(descs);

    let url_list = list!(url = url, description = description);

    url_list.into_robj()
}

fn as_point_sfc(values: Vec<Option<(f64, f64)>>) -> Robj {
    let mut n_empty = 0;
    let list: Vec<Robj> = values
        .into_iter()
        .map(|opt| {
            let coords = match opt {
                Some((lon, lat)) => Robj::from(vec![lon, lat]),
                None => {
                    n_empty += 1;
                    Robj::from(vec![f64::NAN, f64::NAN])
                }
            };
            let mut robj = Robj::from(coords);
            robj.set_class(&["XY", "POINT", "sfg"]).unwrap();
            robj
        })
        .collect();

    as_sfc(Robj::from(list), "point", n_empty)
}

fn as_line_sfc(values: Vec<Option<Vec<(f64, f64)>>>) -> Robj {
    let mut n_empty = 0;
    let list: Vec<Robj> = values
        .into_iter()
        .map(|opt| match opt {
            Some(line) => {
                let flat_coords: Vec<f64> = line.iter().flat_map(|(x, y)| vec![*x, *y]).collect();
                let matrix = RMatrix::new_matrix(line.len(), 2, |r, c| flat_coords[r * 2 + c]);
                let mut robj = Robj::from(matrix);
                robj.set_class(&["XY", "LINESTRING", "sfg"]).unwrap();
                robj
            }
            None => {
                n_empty += 1;
                let empty_matrix = RMatrix::new_matrix(0, 2, |_, _| 0.0);
                let mut robj = Robj::from(empty_matrix);
                robj.set_class(&["XY", "LINESTRING", "sfg"]).unwrap();
                robj
            }
        })
        .collect();

    as_sfc(Robj::from(list), "linestring", n_empty)
}

fn as_polygon_sfc(values: Vec<Option<Vec<Vec<(f64, f64)>>>>) -> Robj {
    let mut n_empty = 0;
    let list: Vec<Robj> = values
        .into_iter()
        .map(|opt| match opt {
            Some(polygon) => {
                let rings: Vec<Robj> = polygon
                    .into_iter()
                    .map(|ring| {
                        let flat_coords: Vec<f64> =
                            ring.iter().flat_map(|(x, y)| vec![*x, *y]).collect();
                        let matrix =
                            RMatrix::new_matrix(ring.len(), 2, |r, c| flat_coords[r * 2 + c]);
                        Robj::from(matrix)
                    })
                    .collect();

                let mut robj = Robj::from(rings);
                robj.set_class(&["XY", "POLYGON", "sfg"]).unwrap();
                robj
            }
            None => {
                n_empty += 1;
                let mut robj = Robj::from(List::from_values(Vec::<Robj>::new()));
                robj.set_class(&["XY", "POLYGON", "sfg"]).unwrap();
                robj
            }
        })
        .collect();

    as_sfc(Robj::from(list), "polygon", n_empty)
}

fn as_multipoint_sfc(values: Vec<Option<Vec<(f64, f64)>>>) -> Robj {
    let mut n_empty = 0;
    let list: Vec<Robj> = values
        .into_iter()
        .map(|opt| match opt {
            Some(multipoint) => {
                let flat_coords: Vec<f64> =
                    multipoint.iter().flat_map(|(x, y)| vec![*x, *y]).collect();
                let matrix =
                    RMatrix::new_matrix(multipoint.len(), 2, |r, c| flat_coords[r * 2 + c]);
                let mut robj = Robj::from(matrix);
                robj.set_class(&["XY", "MULTIPOINT", "sfg"]).unwrap();
                robj
            }
            None => {
                n_empty += 1;
                let empty_matrix = RMatrix::new_matrix(0, 2, |_, _| 0.0);
                let mut robj = Robj::from(empty_matrix);
                robj.set_class(&["XY", "MULTIPOINT", "sfg"]).unwrap();
                robj
            }
        })
        .collect();

    as_sfc(Robj::from(list), "multipoint", n_empty)
}

fn as_multiline_sfc(values: Vec<Option<Vec<Vec<(f64, f64)>>>>) -> Robj {
    let mut n_empty = 0;
    let list: Vec<Robj> = values
        .into_iter()
        .map(|opt| match opt {
            Some(multilinestring) => {
                let lines: Vec<Robj> = multilinestring
                    .into_iter()
                    .map(|line| {
                        let flat_coords: Vec<f64> =
                            line.iter().flat_map(|(x, y)| vec![*x, *y]).collect();
                        let matrix =
                            RMatrix::new_matrix(line.len(), 2, |r, c| flat_coords[r * 2 + c]);
                        Robj::from(matrix)
                    })
                    .collect();

                let mut robj = Robj::from(lines);
                robj.set_class(&["XY", "MULTILINESTRING", "sfg"]).unwrap();
                robj
            }
            None => {
                n_empty += 1;
                let mut robj = Robj::from(List::from_values(Vec::<Robj>::new()));
                robj.set_class(&["XY", "MULTILINESTRING", "sfg"]).unwrap();
                robj
            }
        })
        .collect();

    as_sfc(Robj::from(list), "multilinestring", n_empty)
}

fn as_multipolygon_sfc(values: Vec<Option<Vec<Vec<Vec<(f64, f64)>>>>>) -> Robj {
    let mut n_empty = 0;
    let list: Vec<Robj> = values
        .into_iter()
        .map(|opt| match opt {
            Some(multipolygon) => {
                let exterior_list: Vec<Robj> = multipolygon
                    .into_iter()
                    .map(|polygon| {
                        let rings: Vec<Robj> = polygon
                            .into_iter()
                            .map(|ring| {
                                let flat_coords: Vec<f64> =
                                    ring.iter().flat_map(|(x, y)| vec![*x, *y]).collect();
                                let matrix = RMatrix::new_matrix(ring.len(), 2, |r, c| {
                                    flat_coords[r * 2 + c]
                                });
                                Robj::from(matrix)
                            })
                            .collect();
                        Robj::from(rings)
                    })
                    .collect();

                let mut robj = Robj::from(exterior_list);
                robj.set_class(&["XY", "MULTIPOLYGON", "sfg"]).unwrap();
                robj
            }
            None => {
                n_empty += 1;
                let mut robj = Robj::from(List::from_values(Vec::<Robj>::new()));
                robj.set_class(&["XY", "MULTIPOLYGON", "sfg"]).unwrap();
                robj
            }
        })
        .collect();

    as_sfc(Robj::from(list), "multipolygon", n_empty)
}

fn as_location_list(
    coords: Vec<Option<(f64, f64)>>,
    addresses: Vec<Option<String>>,
    cities: Vec<Option<String>>,
    states: Vec<Option<String>>,
    zips: Vec<Option<String>>,
) -> Robj {
    let geometry = as_point_sfc(coords);
    let address = as_character(addresses);
    let city = as_character(cities);
    let state = as_character(states);
    let zip = as_character(zips);

    let location_list = list!(
        geometry = geometry,
        address = address,
        city = city,
        state = state,
        zip = zip
    );

    location_list.into_robj()
}

fn empty_bbox() -> Robj {
    let mut bbox =
        Doubles::from_values([Rfloat::na(), Rfloat::na(), Rfloat::na(), Rfloat::na()]).into_robj();

    bbox.set_names(&["xmin", "ymin", "xmax", "ymax"]).unwrap();
    bbox
}

pub fn as_sfc(mut list_col: Robj, geom_type: &str, n_empty: i32) -> Robj {
    let class_name = format!("sfc_{}", geom_type.to_uppercase());

    list_col
        .set_class(&[&class_name, "sfc"])
        .unwrap()
        .set_attrib("precision", 0f64)
        .unwrap()
        .set_attrib("n_empty", n_empty)
        .unwrap()
        .set_attrib("bbox", empty_bbox())
        .unwrap()
        .set_attrib("crs", R!("sf::st_crs(4326)"))
        .unwrap();
    list_col
}
