mod parse;
mod process;

use chrono_tz::Tz;
use extendr_api::prelude::*;
use parse::*;
use process::{as_rlist, Column};
use serde_json::Value;

#[extendr]
fn parse_data_json(
    raw_json: List,
    header_col_names: &str,
    header_col_types: &str,
    meta_url: &str,
) -> List {
    let col_names: Vec<String> =
        serde_json::from_str(header_col_names).expect("Failed to parse JSON array");
    let col_types: Vec<String> =
        serde_json::from_str(header_col_types).expect("Failed to parse JSON array");
    let rows: Vec<Value> = raw_json
        .iter()
        .flat_map(|(_, robj)| {
            let bytes = robj.as_raw_slice().unwrap();
            let parsed: Vec<Value> = serde_json::from_slice(bytes)
                .expect("Failed to parse JSON");
            parsed
        })
        .collect();

    let mut columns: Vec<Column> = col_types
        .iter()
        .map(|ty| match ty.as_str() {
            "boolean" => Column::Boolean(Vec::with_capacity(rows.len())),
            "number" => Column::Number(Vec::with_capacity(rows.len())),
            "fixed_timestamp" => Column::FixedTimestamp(Vec::with_capacity(rows.len())),
            "floating_timestamp" => Column::FloatingTimestamp(Vec::with_capacity(rows.len())),
            "text" | "row_identifier" | "row_version" => Column::Text(Vec::with_capacity(rows.len())),
            "url" => Column::Url((
                Vec::with_capacity(rows.len()),
                Vec::with_capacity(rows.len()),
            )),
            "photo" => Column::Photo(Vec::with_capacity(rows.len())),
            "document" => Column::Document(Vec::with_capacity(rows.len())),
            "point" => Column::Point(Vec::with_capacity(rows.len())),
            "line" => Column::Line(Vec::with_capacity(rows.len())),
            "polygon" => Column::Polygon(Vec::with_capacity(rows.len())),
            "multipoint" => Column::MultiPoint(Vec::with_capacity(rows.len())),
            "multiline" => Column::MultiLine(Vec::with_capacity(rows.len())),
            "multipolygon" => Column::MultiPolygon(Vec::with_capacity(rows.len())),
            "location" => Column::Location((
                Vec::with_capacity(rows.len()),
                Vec::with_capacity(rows.len()),
                Vec::with_capacity(rows.len()),
                Vec::with_capacity(rows.len()),
                Vec::with_capacity(rows.len()),
            )),
            _ => unreachable!("Unsupported type"),
        })
        .collect();

    // get the R timezone so that floating timestamps are read correctly
    let tz_str = R!("Sys.timezone()")
        .ok()
        .and_then(|robj| robj.as_str().map(|s| s.to_string()))
        .filter(|s| !s.is_empty())
        .unwrap_or_else(|| "UTC".to_string());
    let tz: Tz = tz_str.parse().unwrap_or(chrono_tz::UTC);

    for row in &rows {
        for (i, (col_name, _col_type)) in col_names.iter().zip(col_types.iter()).enumerate() {
            let val = row.get(col_name);
            match &mut columns[i] {
                Column::Boolean(vec) => {
                    vec.push(parse_boolean(val));
                }
                Column::Number(vec) => {
                    vec.push(parse_number(val));
                }
                Column::FixedTimestamp(vec) => {
                    vec.push(parse_fixed_timestamp(val));
                }
                Column::FloatingTimestamp(vec) => {
                    vec.push(parse_floating_timestamp(val, tz));
                }
                Column::Text(vec) => {
                    vec.push(parse_text(val));
                }
                Column::Url((urls, descs)) => {
                    let (url_val, desc_val) = parse_url(val);
                    urls.push(url_val);
                    descs.push(desc_val);
                }
                Column::Photo(vec) => {
                    vec.push(parse_photo(val, meta_url));
                }
                Column::Document(vec) => {
                    vec.push(parse_document(val, meta_url));
                }
                Column::Point(vec) => {
                    vec.push(parse_point(val));
                }
                Column::Line(vec) => {
                    vec.push(parse_line(val));
                }
                Column::Polygon(vec) => {
                    vec.push(parse_polygon(val));
                }
                Column::MultiPoint(vec) => {
                    vec.push(parse_multipoint(val));
                }
                Column::MultiLine(vec) => {
                    vec.push(parse_multiline(val));
                }
                Column::MultiPolygon(vec) => {
                    vec.push(parse_multipolygon(val));
                }
                Column::Location((coords, addresses, cities, states, zips)) => {
                    let (latlon, addr, city, state, zip) = parse_location(val);
                    coords.push(latlon);
                    addresses.push(addr);
                    cities.push(city);
                    states.push(state);
                    zips.push(zip);
                }
            }
        }
    }

    as_rlist(col_names, columns)
}

// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
    mod socratadata;
    fn parse_data_json;
}
