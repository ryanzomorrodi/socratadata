use chrono::TimeZone;
use chrono_tz::Tz;
use serde_json::Value;

pub fn parse_boolean(val: Option<&Value>) -> Option<bool> {
    val.and_then(Value::as_bool)
}
pub fn parse_number(val: Option<&Value>) -> Option<f64> {
    val.and_then(|v| v.as_str())
        .and_then(|s| s.parse::<f64>().ok())
}

pub fn parse_fixed_timestamp(val: Option<&Value>) -> Option<f64> {
    val.and_then(Value::as_str)
        .and_then(|s| chrono::DateTime::parse_from_rfc3339(s).ok())
        .map(|dt| dt.to_utc().timestamp() as f64)
}

pub fn parse_floating_timestamp(val: Option<&Value>, tz: Tz) -> Option<f64> {
    val.and_then(Value::as_str).and_then(|s| {
        chrono::NaiveDateTime::parse_from_str(s, "%Y-%m-%dT%H:%M:%S%.3f")
            .ok()
            .and_then(|naive_dt| {
                tz.from_local_datetime(&naive_dt)
                    .single()
                    .map(|dt| dt.timestamp() as f64)
            })
    })
}

pub fn parse_text(val: Option<&Value>) -> Option<String> {
    val.and_then(Value::as_str).map(str::to_string)
}

pub fn parse_url(val: Option<&Value>) -> (Option<String>, Option<String>) {
    let url_opt = val
        .and_then(|ud| ud.get("url"))
        .and_then(|u| u.as_str())
        .map(|s| s.to_string());

    let desc_opt = val
        .and_then(|ud| ud.get("description"))
        .and_then(|d| d.as_str())
        .map(|s| s.to_string());

    (url_opt, desc_opt)
}

pub fn parse_photo(val: Option<&Value>, meta_url: &str) -> Option<String> {
    val.and_then(|v| v.as_str())
        .map(|id| format!("{}/files/{}", meta_url, id))
}

pub fn parse_document(val: Option<&Value>, meta_url: &str) -> Option<String> {
    val.and_then(|v| v.as_object())
        .map(|map| {
            let file_id = map.get("file_id")?.as_str()?;
            let filename = map.get("filename").and_then(|v| v.as_str()).unwrap_or("");
            let content_type = map
                .get("content_type")
                .and_then(|v| v.as_str())
                .unwrap_or("");
            Some(format!(
                "{}/files/{}?filename={}&content_type={}",
                meta_url, file_id, filename, content_type
            ))
        })
        .flatten()
}

pub fn parse_point(val: Option<&Value>) -> Option<(f64, f64)> {
    val.and_then(|v| {
        v.get("coordinates")
            .and_then(|coords| coords.as_array())
            .and_then(|arr| {
                if arr.len() == 2 {
                    Some((arr[0].as_f64()?, arr[1].as_f64()?))
                } else {
                    None
                }
            })
    })
}

pub fn parse_line(val: Option<&Value>) -> Option<Vec<(f64, f64)>> {
    val.and_then(|v| {
        v.get("coordinates").and_then(|coords| {
            coords.as_array().map(|arr| {
                arr.iter()
                    .filter_map(|pt| {
                        if let Some(array) = pt.as_array() {
                            if array.len() == 2 {
                                Some((array[0].as_f64()?, array[1].as_f64()?))
                            } else {
                                None
                            }
                        } else {
                            None
                        }
                    })
                    .collect::<Vec<(f64, f64)>>()
            })
        })
    })
}

pub fn parse_polygon(val: Option<&Value>) -> Option<Vec<Vec<(f64, f64)>>> {
    val.and_then(|v| {
        v.get("coordinates").and_then(|rings| {
            rings.as_array().map(|ring_arr| {
                ring_arr
                    .iter()
                    .map(|ring| {
                        ring.as_array()
                            .unwrap()
                            .iter()
                            .map(|point| {
                                let lon = point[0].as_f64().unwrap_or(f64::NAN);
                                let lat = point[1].as_f64().unwrap_or(f64::NAN);
                                (lon, lat)
                            })
                            .collect::<Vec<(f64, f64)>>()
                    })
                    .collect::<Vec<Vec<(f64, f64)>>>()
            })
        })
    })
}

pub fn parse_multipoint(val: Option<&Value>) -> Option<Vec<(f64, f64)>> {
    val.and_then(|v| {
        v.get("coordinates").and_then(|coords| {
            coords.as_array().map(|arr| {
                arr.iter()
                    .filter_map(|pt| {
                        if let Some(array) = pt.as_array() {
                            if array.len() == 2 {
                                Some((array[0].as_f64()?, array[1].as_f64()?))
                            } else {
                                None
                            }
                        } else {
                            None
                        }
                    })
                    .collect::<Vec<(f64, f64)>>()
            })
        })
    })
}

pub fn parse_multiline(val: Option<&Value>) -> Option<Vec<Vec<(f64, f64)>>> {
    val.and_then(|v| {
        v.get("coordinates").and_then(|lines| {
            lines.as_array().map(|lines_arr| {
                lines_arr
                    .iter()
                    .map(|line| {
                        line.as_array()
                            .unwrap()
                            .iter()
                            .map(|point| {
                                let lon = point[0].as_f64().unwrap_or(f64::NAN);
                                let lat = point[1].as_f64().unwrap_or(f64::NAN);
                                (lon, lat)
                            })
                            .collect::<Vec<(f64, f64)>>()
                    })
                    .collect::<Vec<Vec<(f64, f64)>>>()
            })
        })
    })
}

pub fn parse_multipolygon(val: Option<&Value>) -> Option<Vec<Vec<Vec<(f64, f64)>>>> {
    val.and_then(|v| {
        v.get("coordinates").and_then(|polygons| {
            polygons.as_array().map(|poly_arr| {
                poly_arr
                    .iter()
                    .map(|poly| {
                        poly.as_array()
                            .unwrap()
                            .iter()
                            .map(|ring| {
                                ring.as_array()
                                    .unwrap()
                                    .iter()
                                    .map(|point| {
                                        let lon = point[0].as_f64().unwrap_or(f64::NAN);
                                        let lat = point[1].as_f64().unwrap_or(f64::NAN);
                                        (lon, lat)
                                    })
                                    .collect::<Vec<(f64, f64)>>()
                            })
                            .collect::<Vec<Vec<(f64, f64)>>>()
                    })
                    .collect::<Vec<Vec<Vec<(f64, f64)>>>>()
            })
        })
    })
}

pub fn parse_location(
    val: Option<&Value>,
) -> (
    Option<(f64, f64)>,
    Option<String>,
    Option<String>,
    Option<String>,
    Option<String>,
) {
    let location = val.and_then(|v| v.as_object());

    let lat = location
        .and_then(|loc| loc.get("latitude"))
        .and_then(|v| v.as_str())
        .and_then(|s| s.parse::<f64>().ok());

    let lon = location
        .and_then(|loc| loc.get("longitude"))
        .and_then(|v| v.as_str())
        .and_then(|s| s.parse::<f64>().ok());

    let latlon = match (lat, lon) {
        (Some(lat), Some(lon)) => Some((lat, lon)),
        _ => None,
    };

    let human_address = location
        .and_then(|loc| loc.get("human_address"))
        .and_then(|v| {
            if let Some(s) = v.as_str() {
                serde_json::from_str::<serde_json::Map<String, Value>>(s).ok()
            } else {
                v.as_object().cloned()
            }
        });

    let addr = human_address
        .as_ref()
        .and_then(|ha| ha.get("address"))
        .and_then(|v| v.as_str())
        .map(str::to_string);

    let city = human_address
        .as_ref()
        .and_then(|ha| ha.get("city"))
        .and_then(|v| v.as_str())
        .map(str::to_string);

    let state = human_address
        .as_ref()
        .and_then(|ha| ha.get("state"))
        .and_then(|v| v.as_str())
        .map(str::to_string);

    let zip = human_address
        .as_ref()
        .and_then(|ha| ha.get("zip"))
        .and_then(|v| v.as_str())
        .map(str::to_string);

    (latlon, addr, city, state, zip)
}
