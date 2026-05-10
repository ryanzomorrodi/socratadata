use crate::{
    data::types::{col_type_mapper, SocColType},
    utils::{IntoPosixct, IntoSfc, IntoTibble},
};
use chrono::{DateTime, TimeZone, Utc};
use extendr_api::prelude::*;
use serde_json::Value;
use std::str::FromStr;

pub fn parse_data_json(
    resp_bodies: Vec<Robj>,
    names_header: &str,
    types_header: &str,
    meta_url: &str,
    tz: &str,
) -> Robj {
    let names: Vec<String> = serde_json::from_str(names_header).unwrap();
    let types: Vec<String> = serde_json::from_str(types_header).unwrap();
    let rows: Vec<Value> = resp_bodies
        .iter()
        .flat_map(|robj| {
            let bytes = robj.as_raw_slice().unwrap();
            let parsed: Vec<Value> = serde_json::from_slice(bytes).unwrap();
            parsed
        })
        .collect();
    let n_cols = names.len();
    let n_rows = rows.len();
    let col_types = types
        .iter()
        .map(|t| SocColType::from_str(t.as_str()).unwrap())
        .collect::<Vec<SocColType>>();
    let col_names: Vec<String> = names.iter().map(|n| n.to_string()).collect();

    let mut cols: Vec<Vec<Option<Value>>> = vec![Vec::with_capacity(n_rows); n_cols];
    for row in rows {
        for (i, name) in col_names.iter().enumerate() {
            let val = row.get(name).cloned().filter(|v| !v.is_null());
            cols[i].push(val);
        }
    }
    let res_vecs = cols
        .into_iter()
        .zip(col_types.iter())
        .map(|(vi, fi)| {
            let col_parser = col_type_mapper(fi, meta_url, tz);
            col_parser(vi)
        })
        .collect::<Vec<Robj>>();

    let result = List::from_names_and_values(col_names, res_vecs)
        .unwrap()
        .into_tibble();

    if col_types.iter().filter(|t| t.is_geometry()).count() == 1 {
        call!("sf::st_as_sf", result).unwrap()
    } else {
        result
    }
}

pub fn parse_numbers(x: Vec<Option<Value>>) -> Doubles {
    x.into_iter()
        .map(|opt| {
            opt.and_then(|val| val.as_str().and_then(|s| s.parse::<f64>().ok()))
                .unwrap_or(f64::na())
        })
        .collect::<Doubles>()
}

pub fn parse_booleans(x: Vec<Option<Value>>) -> Logicals {
    x.into_iter()
        .map(|opt| {
            opt.and_then(|val| val.as_bool())
                .map(Rbool::from)
                .unwrap_or(Rbool::na())
        })
        .collect::<Logicals>()
}

pub fn parse_text(x: Vec<Option<Value>>) -> Strings {
    x.into_iter()
        .map(|opt| {
            opt.and_then(|val| val.as_str().map(|s| s.to_string()))
                .map(Rstr::from)
                .unwrap_or(Rstr::na())
        })
        .collect::<Strings>()
}

pub fn parse_fixed_timestamps(x: Vec<Option<Value>>) -> Robj {
    let datetimes: Vec<Option<DateTime<Utc>>> = x
        .into_iter()
        .map(|opt| {
            opt.and_then(|val| {
                val.as_str()
                    .and_then(|s| DateTime::parse_from_rfc3339(s).ok())
                    .map(|dt| dt.with_timezone(&Utc))
            })
        })
        .collect();

    datetimes.into_posixct()
}

pub fn parse_floating_timestamps(x: Vec<Option<Value>>, tz_str: &str) -> Robj {
    let tz = tz_str.parse().unwrap_or(chrono_tz::UTC);

    let mut res = x
        .into_iter()
        .map(|opt| {
            let s = opt.as_ref().and_then(|v| v.as_str());

            s.and_then(|s_val| {
                chrono::NaiveDateTime::parse_from_str(s_val, "%Y-%m-%dT%H:%M:%S%.3f")
                    .ok()
                    .and_then(|naive_dt| {
                        tz.from_local_datetime(&naive_dt)
                            .single()
                            .map(|dt| dt.timestamp() as f64)
                    })
            })
            .unwrap_or(f64::na())
        })
        .collect::<Doubles>();

    res.set_class(&["POSIXct", "POSIXt"])
        .unwrap()
        .set_attrib("tzone", "")
        .unwrap();

    res.into_robj()
}

pub fn parse_urls(x: Vec<Option<Value>>) -> Robj {
    let (urls, descriptions): (Vec<Rstr>, Vec<Rstr>) = x
        .into_iter()
        .map(|opt| {
            opt.map(|val| {
                let u = val
                    .get("url")
                    .and_then(|v| v.as_str())
                    .map(Rstr::from)
                    .unwrap_or(Rstr::na());

                let d = val
                    .get("description")
                    .and_then(|v| v.as_str())
                    .map(Rstr::from)
                    .unwrap_or(Rstr::na());

                (u, d)
            })
            .unwrap_or((Rstr::na(), Rstr::na()))
        })
        .unzip();

    let res = list!(
        url = Strings::from_values(urls),
        description = Strings::from_values(descriptions)
    );

    res.into_tibble()
}

pub fn parse_photos(x: Vec<Option<Value>>, meta_url: &str) -> Robj {
    x.into_iter()
        .map(|opt| {
            opt.and_then(|val| val.as_str().map(|s| s.to_string()))
                .map(|id| {
                    let full_url = format!("{}/files/{}", meta_url, id);
                    Rstr::from(full_url)
                })
                .unwrap_or(Rstr::na())
        })
        .collect::<Strings>()
        .into_robj()
}

pub fn parse_documents(x: Vec<Option<Value>>, meta_url: &str) -> Robj {
    x.into_iter()
        .map(|opt| {
            opt.and_then(|map| {
                let file_id = map.get("file_id")?.as_str()?;
                let filename = map.get("filename")?.as_str()?;
                let content_type = map.get("content_type")?.as_str()?;

                let full_url = format!(
                    "{}/files/{}?filename={}&content_type={}",
                    meta_url, file_id, filename, content_type
                );
                Some(Rstr::from(full_url))
            })
            .unwrap_or(Rstr::na())
        })
        .collect::<Strings>()
        .into_robj()
}

type Point2D = [f64; 2];

fn as_point(v: &Value) -> Option<Point2D> {
    let arr = v.as_array()?;
    Some([arr.first()?.as_f64()?, arr.get(1)?.as_f64()?])
}

fn extract_vec_coords(opt: Option<Value>) -> Robj {
    let coords = opt.and_then(|v| as_point(v.get("coordinates")?));

    match coords {
        Some(p) => Doubles::from_values(p).into_robj(),
        None => Doubles::from_values([f64::na(), f64::na()]).into_robj(),
    }
}

fn points_to_rmatrix(pts: Vec<Point2D>) -> Robj {
    let n = pts.len();
    RMatrix::new_matrix(n, 2, |r, c| pts[r][c]).into_robj()
}

fn extract_matrix_coords(opt: Option<Value>) -> Robj {
    let pts = opt.and_then(|val| {
        val.get("coordinates")?
            .as_array()?
            .iter()
            .map(as_point)
            .collect::<Option<Vec<_>>>()
    });

    pts.map(points_to_rmatrix)
        .unwrap_or_else(|| points_to_rmatrix(vec![]))
}

fn extract_list_matrix_coords(opt: Option<Value>) -> Robj {
    let list = opt.and_then(|val| {
        val.get("coordinates")?
            .as_array()?
            .iter()
            .map(|pts_val| {
                pts_val
                    .as_array()?
                    .iter()
                    .map(as_point)
                    .collect::<Option<Vec<_>>>()
            })
            .collect::<Option<Vec<Vec<_>>>>()
    });

    list.map(|vec_of_vecs| {
        vec_of_vecs
            .into_iter()
            .map(points_to_rmatrix)
            .collect::<List>()
            .into_robj()
    })
    .unwrap_or_else(|| List::new(0).into_robj())
}

fn extract_nested_list_matrix_coords(opt: Option<Value>) -> Robj {
    let nested = opt.and_then(|val| {
        val.get("coordinates")?
            .as_array()?
            .iter()
            .map(|poly_val| {
                poly_val
                    .as_array()?
                    .iter()
                    .map(|ring| {
                        ring.as_array()?
                            .iter()
                            .map(as_point)
                            .collect::<Option<Vec<_>>>()
                    })
                    .collect::<Option<Vec<Vec<_>>>>()
            })
            .collect::<Option<Vec<Vec<Vec<_>>>>>()
    });

    nested
        .map(|polys| {
            polys
                .into_iter()
                .map(|rings| rings.into_iter().map(points_to_rmatrix).collect::<List>())
                .collect::<List>()
                .into_robj()
        })
        .unwrap_or_else(|| List::new(0).into_robj())
}

fn parse_geometry_collection<F>(x: Vec<Option<Value>>, class_name: &str, extract_fn: F) -> Robj
where
    F: Fn(Option<Value>) -> Robj,
{
    let sfc_class = format!("sfc_{}", class_name);
    let sfg_classes = ["XY", class_name, "sfg"];

    let sfc_list = x
        .into_iter()
        .map(|opt| {
            let mut coords = extract_fn(opt);
            coords.set_class(&sfg_classes).unwrap();
            coords
        })
        .collect::<List>();

    sfc_list.into_sfc(&sfc_class)
}

pub fn parse_points(x: Vec<Option<Value>>) -> Robj {
    parse_geometry_collection(x, "POINT", extract_vec_coords)
}

pub fn parse_lines(x: Vec<Option<Value>>) -> Robj {
    parse_geometry_collection(x, "LINESTRING", extract_matrix_coords)
}

pub fn parse_polygons(x: Vec<Option<Value>>) -> Robj {
    parse_geometry_collection(x, "POLYGON", extract_list_matrix_coords)
}

pub fn parse_multipoints(x: Vec<Option<Value>>) -> Robj {
    parse_geometry_collection(x, "MULTIPOINT", extract_matrix_coords)
}

pub fn parse_multilines(x: Vec<Option<Value>>) -> Robj {
    parse_geometry_collection(x, "MULTILINESTRING", extract_list_matrix_coords)
}

pub fn parse_multipolygons(x: Vec<Option<Value>>) -> Robj {
    parse_geometry_collection(x, "MULTIPOLYGON", extract_nested_list_matrix_coords)
}

fn extract_vec_location(opt: Option<Value>) -> Robj {
    let coords = opt.map(|val| {
        let lat = val
            .get("latitude")
            .and_then(|v| v.as_f64().or_else(|| v.as_str()?.parse().ok()));
        let lon = val
            .get("longitude")
            .and_then(|v| v.as_f64().or_else(|| v.as_str()?.parse().ok()));

        vec![lat, lon]
    });

    match coords {
        Some(c) => Doubles::from_values(c).into_robj(),
        _ => Doubles::from_values([f64::na(), f64::na()]).into_robj(),
    }
}

pub fn parse_locations(mut x: Vec<Option<Value>>) -> Robj {
    let len = x.len();
    let mut addresses = Vec::with_capacity(len);
    let mut cities = Vec::with_capacity(len);
    let mut states = Vec::with_capacity(len);
    let mut zips = Vec::with_capacity(len);

    for opt in x.iter_mut() {
        let addr_raw = opt
            .as_mut()
            .and_then(|v| v.as_object_mut()?.remove("human_address"));

        let mut addr_obj: Option<Value> = addr_raw.and_then(|v| {
            let s = v.as_str()?;
            serde_json::from_str(s).ok()
        });

        let get_field =
            |obj: &mut Option<Value>, key: &str| obj.as_mut()?.as_object_mut()?.remove(key);

        addresses.push(get_field(&mut addr_obj, "address"));
        cities.push(get_field(&mut addr_obj, "city"));
        states.push(get_field(&mut addr_obj, "state"));
        zips.push(get_field(&mut addr_obj, "zip"));
    }

    list!(
        geometry = parse_geometry_collection(x, "POINT", extract_vec_location),
        address = parse_text(addresses),
        city = parse_text(cities),
        state = parse_text(states),
        zip = parse_text(zips)
    )
    .into_tibble()
}
