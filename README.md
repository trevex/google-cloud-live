# `google-cloud-live`

## Bucket for state

### Create a project and bucket to use

```bash
gcloud projects create nvoss-gcloud-live # make sure billing account is attached
gsutil mb -p nvoss-gcloud-live -l europe-west3 -b on gs://nvoss-gcloud-live-tf-state
gsutil versioning set on gs://nvoss-gcloud-live-tf-state
```

### Allow applications such as terragrunt to use your login and set the project:

```bash
gcloud auth application-default login --project nvoss-gcloud-live
```

## Folder structure

The folder structure is kept as flat as possible, so regions or other groupings (e.g. dev, prod, sovereign, ...) are not represented.
However with growing complexity consider introducing additional layers.

The current structure looks as follows:
```
```

## Accessing cluster
```bash
gcloud container clusters get-credentials cluster-default --region europe-west3 --project nvoss-mycorp-shared-dev
```

## Update lockfiles

```bash
terragrunt run-all init -upgrade
```
