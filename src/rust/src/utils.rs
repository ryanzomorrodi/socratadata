use chrono::{DateTime, Utc};
use extendr_api::prelude::*;



pub trait IntoTibble {
    fn into_tibble(self) -> Robj;
}

impl IntoTibble for List {
    fn into_tibble(self) -> Robj {
        let n_rows = self
            .elt(0)
            .ok()
            .and_then(|col: Robj| {
                if col.inherits("tbl_df") {
                    col.as_list()
                        .and_then(|list| list.elt(0).ok())
                        .map(|first_col| first_col.len())
                } else {
                    Some(col.len())
                }
            })
            .unwrap_or(0);
        let row_index = (1..=n_rows).map(|i| i as i32).collect::<Vec<i32>>();

        let mut robj = self.into_robj();

        robj.set_class(&["tbl_df", "tbl", "data.frame"])
            .unwrap()
            .set_attrib("row.names", row_index)
            .unwrap();

        robj
    }
}

pub trait IntoSfc {
    fn into_sfc(self, geom_class: &str) -> Robj;
}

fn is_geom_empty(obj: &Robj) -> bool {
    if obj.is_matrix() {
        obj.nrows() == 0
    } else if obj.is_list() {
        obj.len() == 0
    } else if obj.is_vector() {
        obj.as_real_slice()
            .map_or(true, |s| s.iter().any(|v| v.is_na()))
    } else {
        obj.is_null()
    }
}
impl IntoSfc for List {
    fn into_sfc(self, geom_class: &str) -> Robj {
        let n_empty = self.iter().filter(|(_, obj)| is_geom_empty(obj)).count() as i32;

        let mut robj = self.into_robj();

        let mut bbox =
            Doubles::from_values([Rfloat::na(), Rfloat::na(), Rfloat::na(), Rfloat::na()])
                .into_robj();
        bbox.set_names(&["xmin", "ymin", "xmax", "ymax"]).unwrap();

        robj.set_class(&[geom_class, "sfc"])
            .unwrap()
            .set_attrib("crs", R!("sf::st_crs(4326)"))
            .unwrap()
            .set_attrib("bbox", bbox)
            .unwrap()
            .set_attrib("precision", 0.0)
            .unwrap()
            .set_attrib("n_empty", n_empty)
            .unwrap();

        call!("sf::st_sfc", robj).unwrap()
    }
}

pub trait IntoPosixct {
    fn into_posixct(self) -> Robj;
}

trait ToTimestamp {
    fn to_timestamp(&self) -> f64;
}

impl ToTimestamp for DateTime<Utc> {
    fn to_timestamp(&self) -> f64 {
        self.timestamp() as f64
    }
}

impl ToTimestamp for Option<DateTime<Utc>> {
    fn to_timestamp(&self) -> f64 {
        self.as_ref()
            .map(|dt| dt.timestamp() as f64)
            .unwrap_or(f64::na())
    }
}

impl<T: ToTimestamp> IntoPosixct for Vec<T> {
    fn into_posixct(self) -> Robj {
        let mut robj = self
            .iter()
            .map(|x| x.to_timestamp())
            .collect::<Doubles>()
            .into_robj();

        robj.set_class(&["POSIXct", "POSIXt"]).unwrap();
        robj.set_attrib("tzone", "UTC").unwrap();

        robj
    }
}
