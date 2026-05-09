use crate::data::parse::*;
use extendr_api::prelude::{IntoRobj, Robj};
use serde_json::Value;
use std::str::FromStr;

pub fn col_type_mapper(
    col_type: &SocColType,
    meta_url: &str,
    tz: &str,
) -> Box<dyn Fn(Vec<Option<Value>>) -> Robj> {
    let meta_url = meta_url.to_string();
    let tz = tz.to_string();

    match col_type {
        SocColType::Boolean => Box::new(|x| parse_booleans(x).into_robj()),
        SocColType::Number => Box::new(|x| parse_numbers(x).into_robj()),
        SocColType::Text => Box::new(|x| parse_text(x).into_robj()),
        SocColType::FixedTimestamp => Box::new(parse_fixed_timestamps),
        SocColType::FloatingTimestamp => Box::new(move |x| parse_floating_timestamps(x, &tz)),
        SocColType::Url => Box::new(parse_urls),
        SocColType::Photo => Box::new(move |x| parse_photos(x, &meta_url)),
        SocColType::Document => Box::new(move |x| parse_documents(x, &meta_url)),
        SocColType::Point => Box::new(parse_points),
        SocColType::Line => Box::new(parse_lines),
        SocColType::Polygon => Box::new(parse_polygons),
        SocColType::MultiPoint => Box::new(parse_multipoints),
        SocColType::MultiLine => Box::new(parse_multilines),
        SocColType::MultiPolygon => Box::new(parse_multipolygons),
        SocColType::Location => Box::new(parse_locations),
    }
}
pub enum SocColType {
    Boolean,
    Number,
    FixedTimestamp,
    FloatingTimestamp,
    Text,
    Url,
    Photo,
    Document,
    Point,
    Line,
    Polygon,
    MultiPoint,
    MultiLine,
    MultiPolygon,
    Location,
}

impl SocColType {
    pub fn is_geometry(&self) -> bool {
        matches!(
            self,
            SocColType::Point
                | SocColType::Line
                | SocColType::Polygon
                | SocColType::MultiPoint
                | SocColType::MultiLine
                | SocColType::MultiPolygon
        )
    }
}

impl FromStr for SocColType {
    type Err = ();

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "boolean" => Ok(SocColType::Boolean),
            "number" => Ok(SocColType::Number),
            "fixed_timestamp" => Ok(SocColType::FixedTimestamp),
            "floating_timestamp" => Ok(SocColType::FloatingTimestamp),
            "text" | "row_identifier" | "row_version" => Ok(SocColType::Text),
            "url" => Ok(SocColType::Url),
            "photo" => Ok(SocColType::Photo),
            "document" => Ok(SocColType::Document),
            "point" => Ok(SocColType::Point),
            "line" => Ok(SocColType::Line),
            "polygon" => Ok(SocColType::Polygon),
            "multipoint" => Ok(SocColType::MultiPoint),
            "multiline" => Ok(SocColType::MultiLine),
            "multipolygon" => Ok(SocColType::MultiPolygon),
            "location" => Ok(SocColType::Location),
            _ => Err(()),
        }
    }
}
