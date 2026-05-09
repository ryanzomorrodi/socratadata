use crate::utils::{IntoPosixct, IntoTibble};
use chrono::{DateTime, Utc};
use extendr_api::prelude::*;
use serde::Deserialize;

#[derive(Debug, Deserialize)]
pub struct Response {
    pub results: Vec<SearchResult>,
    #[serde(rename = "resultSetSize")]
    pub _result_set_size: u32,
}

#[derive(Debug, Deserialize)]
pub struct SearchResult {
    pub resource: Resource,
    pub metadata: Metadata,
    pub classification: Classification,
    pub owner: Person,
    pub creator: Person,
    pub permalink: String,
    pub link: String,
}

#[derive(Debug, Deserialize)]
pub struct Resource {
    pub name: String,
    pub id: String,
    pub description: String,
    pub parent_fxf: Vec<String>,
    pub attribution: Option<String>,
    pub attribution_link: Option<String>,
    pub contact_email: Option<String>,
    #[serde(rename = "type")]
    pub resource_type: String,
    #[serde(rename = "updatedAt")]
    pub created: DateTime<Utc>,
    #[serde(rename = "metadata_updated_at")]
    pub updated: DateTime<Utc>,
    #[serde(rename = "createdAt")]
    pub metadata_last_updated: DateTime<Utc>,
    #[serde(rename = "data_updated_at")]
    pub data_last_updated: DateTime<Utc>,
    #[serde(rename = "publication_date")]
    pub published: Option<DateTime<Utc>>,
    pub page_views: PageViews,
    pub columns_name: Vec<String>,
    pub columns_field_name: Vec<String>,
    pub columns_datatype: Vec<String>,
    pub columns_description: Vec<String>,
    pub download_count: u32,
    pub provenance: String,
}

#[derive(Debug, Deserialize)]
pub struct PageViews {
    pub page_views_last_week: u32,
    pub page_views_last_month: u32,
    pub page_views_total: u32,
}

#[derive(Debug, Deserialize)]
pub struct Classification {
    pub categories: Vec<String>,
    pub tags: Vec<String>,
    pub domain_category: Option<String>,
    pub domain_tags: Vec<String>,
    pub domain_metadata: Vec<DomainMetadata>,
}

#[derive(Debug, Deserialize)]
pub struct DomainMetadata {
    pub key: String,
    pub value: String,
}

#[derive(Debug, Deserialize)]
pub struct Metadata {
    pub domain: String,
    pub license: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct Person {
    pub id: String,
    pub display_name: String,
}

pub fn parse_discovery_json(resp_body: Robj) -> Robj {
    let bytes = resp_body.as_raw_slice().unwrap();
    let data: Response = serde_json::from_slice(bytes).unwrap();
    let df_len = data.results.len();

    let mut names = Vec::with_capacity(df_len);
    let mut ids = Vec::with_capacity(df_len);
    let mut parent_ids = Vec::with_capacity(df_len);
    let mut attributions = Vec::with_capacity(df_len);
    let mut attribution_links = Vec::with_capacity(df_len);
    let mut contact_emails = Vec::with_capacity(df_len);
    let mut resource_types = Vec::with_capacity(df_len);
    let mut owner_ids = Vec::with_capacity(df_len);
    let mut owner_names = Vec::with_capacity(df_len);
    let mut creator_ids = Vec::with_capacity(df_len);
    let mut creator_names = Vec::with_capacity(df_len);
    let mut provenances = Vec::with_capacity(df_len);
    let mut descriptions = Vec::with_capacity(df_len);
    let mut createds = Vec::with_capacity(df_len);
    let mut updateds = Vec::with_capacity(df_len);
    let mut data_last_updateds = Vec::with_capacity(df_len);
    let mut metadata_last_updateds = Vec::with_capacity(df_len);
    let mut publisheds = Vec::with_capacity(df_len);
    let mut categories = Vec::with_capacity(df_len);
    let mut tags = Vec::with_capacity(df_len);
    let mut domain_categories = Vec::with_capacity(df_len);
    let mut domain_tags = Vec::with_capacity(df_len);
    let mut domain_metadata = Vec::with_capacity(df_len);
    let mut columns = Vec::with_capacity(df_len);
    let mut permalinks = Vec::with_capacity(df_len);
    let mut links = Vec::with_capacity(df_len);
    let mut domains = Vec::with_capacity(df_len);
    let mut licenses = Vec::with_capacity(df_len);
    let mut page_views_last_weeks = Vec::with_capacity(df_len);
    let mut page_views_last_months = Vec::with_capacity(df_len);
    let mut page_views_totals = Vec::with_capacity(df_len);
    let mut downloads = Vec::with_capacity(df_len);

    for r in data.results {
        names.push(r.resource.name);
        ids.push(r.resource.id);
        parent_ids.push(r.resource.parent_fxf.into_robj());
        attributions.push(r.resource.attribution);
        attribution_links.push(r.resource.attribution_link);
        contact_emails.push(r.resource.contact_email);
        resource_types.push(r.resource.resource_type);
        owner_ids.push(r.owner.id);
        owner_names.push(r.owner.display_name);
        creator_ids.push(r.creator.id);
        creator_names.push(r.creator.display_name);
        provenances.push(r.resource.provenance);
        descriptions.push(r.resource.description);
        createds.push(r.resource.created);
        updateds.push(r.resource.updated);
        data_last_updateds.push(r.resource.data_last_updated);
        metadata_last_updateds.push(r.resource.metadata_last_updated);
        publisheds.push(r.resource.published);
        categories.push(r.classification.categories.into_robj());
        tags.push(r.classification.tags.into_robj());
        domain_categories.push(r.classification.domain_category);
        domain_tags.push(r.classification.domain_tags.into_robj());
        let (keys, values): (Vec<String>, Vec<String>) = r
            .classification
            .domain_metadata
            .into_iter()
            .map(|dm| (dm.key, dm.value))
            .unzip();
        domain_metadata.push(
            List::from_names_and_values(keys, values)
                .unwrap()
                .into_robj(),
        );
        columns.push(
            list!(
                name = r.resource.columns_name.into_robj(),
                label = r.resource.columns_field_name.into_robj(),
                description = r.resource.columns_description.into_robj(),
                datatype = r.resource.columns_datatype.into_robj()
            )
            .into_tibble(),
        );
        permalinks.push(r.permalink);
        links.push(r.link);
        domains.push(r.metadata.domain);
        licenses.push(r.metadata.license);
        page_views_last_weeks.push(r.resource.page_views.page_views_last_week);
        page_views_last_months.push(r.resource.page_views.page_views_last_month);
        page_views_totals.push(r.resource.page_views.page_views_total);
        downloads.push(r.resource.download_count);
    }

    list!(
        id = ids,
        parent_ids = parent_ids,
        name = names,
        attribution = attributions,
        attribution_link = attribution_links,
        contact_email = contact_emails,
        resource_type = resource_types,
        owner = list!(id = owner_ids, name = owner_names).into_tibble(),
        creator = list!(id = creator_ids, name = creator_names).into_tibble(),
        provenance = provenances,
        description = descriptions,
        created = createds.into_posixct(),
        updated = updateds.into_posixct(),
        published = publisheds.into_posixct(),
        data_last_updated = data_last_updateds.into_posixct(),
        metadata_last_updated = metadata_last_updateds.into_posixct(),
        categories = categories.into_iter().collect::<List>(),
        tags = tags.into_iter().collect::<List>(),
        domain_categories = domain_categories,
        domain_tags = domain_tags.into_iter().collect::<List>(),
        domain_metadata = domain_metadata.into_iter().collect::<List>(),
        columns = columns.into_iter().collect::<List>(),
        permalink = permalinks,
        link = links,
        domain = domains,
        license = licenses,
        page_views_last_week = page_views_last_weeks,
        page_views_last_month = page_views_last_months,
        page_views_total = page_views_totals,
        downloads = downloads
    )
    .into_tibble()
}
