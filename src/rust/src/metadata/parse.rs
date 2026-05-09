use chrono::{DateTime, Utc};
use extendr_api::prelude::*;
use serde::Deserialize;
use std::collections::HashMap;

use crate::utils::{IntoPosixct, IntoTibble};

#[derive(Debug, Deserialize)]
pub struct Response {
    pub id: String,
    pub name: String,
    pub attribution: Option<String>,
    #[serde(rename = "attributionLink")]
    pub attribution_link: Option<String>,
    #[serde(rename = "assetType")]
    pub resource_type: String,
    pub owner: Person,
    pub provenance: String,
    pub description: Option<String>,
    #[serde(rename = "createdAt", with = "chrono::serde::ts_seconds")]
    pub created: DateTime<Utc>,
    #[serde(rename = "publicationDate", with = "chrono::serde::ts_seconds_option")]
    pub published: Option<DateTime<Utc>>,
    #[serde(rename = "rowsUpdatedAt", with = "chrono::serde::ts_seconds")]
    pub data_last_updated: DateTime<Utc>,
    #[serde(rename = "viewLastModified", with = "chrono::serde::ts_seconds")]
    pub metadata_last_updated: DateTime<Utc>,
    #[serde(rename = "category")]
    pub domain_category: Option<String>,
    #[serde(rename = "tags", default)]
    pub domain_tags: Vec<String>,
    #[serde(rename = "metadata")]
    pub domain_metadata: Metadata,
    pub columns: Vec<Column>,
    pub license: Option<License>,
    #[serde(rename = "viewCount")]
    pub page_views_total: u32,
    #[serde(rename = "downloadCount")]
    pub downloads: u32,
}

#[derive(Debug, Deserialize)]
pub struct Metadata {
    pub custom_fields: Option<CustomFields>,
}

#[derive(Debug, Deserialize)]
pub struct CustomFields {
    #[serde(rename = "Metadata")]
    pub metadata: Option<HashMap<String, String>>,
}

#[derive(Debug, Deserialize)]
pub struct Person {
    pub id: String,
    #[serde(rename = "displayName")]
    pub display_name: String,
}

#[derive(Debug, Deserialize)]
pub struct Column {
    #[serde(rename = "fieldName")]
    pub name: String,
    #[serde(rename = "name")]
    pub label: String,
    pub description: Option<String>,
    #[serde(rename = "dataTypeName")]
    pub datatype: String,
}

#[derive(Debug, Deserialize)]
pub struct License {
    pub name: String,
}

pub fn parse_metadata_json(resp_body: Robj) -> Robj {
    let bytes = resp_body.as_raw_slice().unwrap();
    let data: Response = serde_json::from_slice(bytes).unwrap();

    let columns = list!(
        name = data
            .columns
            .iter()
            .map(|c| c.name.as_str())
            .collect::<Strings>(),
        label = data
            .columns
            .iter()
            .map(|c| c.label.as_str())
            .collect::<Strings>(),
        description = data
            .columns
            .iter()
            .map(|c| match c.description.as_deref() {
                Some(s) => Rstr::from(s),
                None => Rstr::na(),
            })
            .collect::<Strings>(),
        datatype = data
            .columns
            .iter()
            .map(|c| c.datatype.as_str())
            .collect::<Strings>()
    )
    .into_tibble();

    let domain_metadata = data
        .domain_metadata
        .custom_fields
        .and_then(|cf| cf.metadata)
        .as_ref()
        .map(|map| {
            let (keys, values): (Vec<_>, Vec<_>) =
                map.iter().map(|(k, v)| (k, v.into_robj())).unzip();
            List::from_names_and_values(keys, values).unwrap()
        })
        .unwrap_or_else(|| List::from_values(Vec::<Robj>::new()));

    let mut result = list!(
        id = data.id,
        name = data.name,
        attribution = data.attribution,
        attribution_link = data.attribution_link,
        resource_type = data.resource_type,
        owner = list!(id = data.owner.id, display_name = data.owner.display_name),
        provenance = data.provenance,
        description = data.description,
        created = vec![data.created].into_posixct(),
        published = vec![data.published].into_posixct(),
        data_last_updated = vec![data.data_last_updated].into_posixct(),
        metadata_last_updated = vec![data.metadata_last_updated].into_posixct(),
        domain_category = data.domain_category,
        domain_tags = data.domain_tags,
        domain_metadata = domain_metadata,
        columns = columns,
        license = data.license.map(|l| l.name),
        page_views_total = data.page_views_total as i32,
        downloads = data.downloads as i32
    );
    result.set_class(&["soc_meta"]).unwrap();

    result.into_robj()
}
