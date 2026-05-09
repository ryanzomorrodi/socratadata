mod data;
mod discovery;
mod metadata;
mod utils;

use crate::{
    data::parse::parse_data_json, discovery::parse::parse_discovery_json,
    metadata::parse::parse_metadata_json,
};
use extendr_api::prelude::*;
use serde_json::Value;

#[extendr]
fn parse_data_resps(resps: List, meta_url: &str, tz: &str) -> Robj {
    let bodies = resps
        .iter()
        .map(|(_, resp)| {
            let resp_list = resp.as_list().unwrap();

            resp_list.dollar("body").unwrap()
        })
        .collect::<Vec<_>>();

    let fields_header_str = resps
        .first()
        .unwrap()
        .dollar("headers")
        .unwrap()
        .dollar("X-SODA2-Fields")
        .unwrap()
        .as_str()
        .unwrap();

    let types_header_str = resps
        .first()
        .unwrap()
        .dollar("headers")
        .unwrap()
        .dollar("X-SODA2-Types")
        .unwrap()
        .as_str()
        .unwrap();

    parse_data_json(bodies, fields_header_str, types_header_str, meta_url, tz)
}

#[extendr]
fn is_empty_raw_json(raw_json: Robj) -> bool {
    let bytes = raw_json.as_raw_slice().unwrap();

    match serde_json::from_slice::<Value>(bytes) {
        Ok(Value::Array(arr)) => arr.is_empty(),
        Ok(Value::Object(map)) => map.is_empty(),
        Ok(Value::Null) => true,
        Ok(_) => false,
        Err(_) => false,
    }
}

#[derive(Debug, IntoDataFrameRow)]
struct SearchResultRow {
    name: String,
    id: String,
    download_count: f64,
    column_names: Robj,
}

#[extendr]
pub fn parse_discovery_resp(resp: Robj) -> Robj {
    let body = resp.dollar("body").unwrap();
    parse_discovery_json(body)
}

#[extendr]
pub fn parse_metadata_resp(resp: Robj) -> Robj {
    let body = resp.dollar("body").unwrap();
    parse_metadata_json(body)
}

extendr_module! {
    mod socratadata;
    fn parse_data_resps;
    fn is_empty_raw_json;
    fn parse_discovery_resp;
    fn parse_metadata_resp;
}
