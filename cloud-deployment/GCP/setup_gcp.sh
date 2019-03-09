#!/bin/bash

set -e
set -o pipefail

# how to get the GCP billing account details
# gcloud organizations list
# gcloud beta billing accounts list

echo "=============| creating a new GCP project |============"
create_new_project() {
    gcloud projects create ${TF_ADMIN} \
    # --organization=${TF_VAR_org_id} \
    --set-as-default
}

echo "==============| link a project to a billing account |=============="
link_it_to_your_billing_account() {
    gcloud beta billing projects link ${TF_ADMIN} \
    --billing-account=${TF_VAR_billing_account}
}

echo "======================| creating a service account |================="
create_service_account() {
    gcloud iam service-accounts create terraform \
    --display-name="Terraform admin account"
}

echo "=================| downloading service account keys |================="
download_JSON_credentials() {
    gcloud iam service-accounts keys create ${TF_CREDS} \
    --iam-account=terraform@${TF_ADMIN}.iam.gserviceaccount.com
}

echo "====================| grant permission to project |================="
grant_service_account_permission_to_view_the_Admin_Project_and_manage_Cloud_Storage() {
    gcloud projects add-iam-policy-binding ${TF_ADMIN} \
    --member=serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
    --role=roles/viewer

    gcloud projects add-iam-policy-binding ${TF_ADMIN} \
    --member=serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
    --role=roles/storage.admin
}

echo "=====================| enable services on service account |=================="
enable_actions_that_Terraform_service_account_has_been_granted_to_perform_on_the_API() {
    gcloud services enable cloudresourcemanager.googleapis.com
    gcloud services enable cloudbilling.googleapis.com
    gcloud services enable iam.googleapis.com
    gcloud services enable compute.googleapis.com
}

echo "=====================| grant service accoutn permission to create projects |========================"
grant_the_service_account_permission_to_create_projects_and_assign_billing_accounts() {
    gcloud beta projects add-iam-policy-binding ${TF_VAR_org_id} \
    --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
    --role roles/resourcemanager.projectCreator

    gcloud beta projects add-iam-policy-binding ${TF_VAR_org_id} \
    --member=serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
    --role=roles/billing.user
}

echo "============================| create remote bucket |=========================="
create_the_remote_backend_bucket_in_Cloud_Storage() {
    gsutil mb -p ${TF_ADMIN} gs://${TF_ADMIN}
}

echo "===========================| enable bucket versioning |==================="
enable_versioning_for_remote_bucket() {
    gsutil versioning set on gs://${TF_ADMIN}
}


main() {
    if create_new_project
    then
        link_it_to_your_billing_account
        create_service_account
        download_JSON_credentials
        grant_service_account_permission_to_view_the_Admin_Project_and_manage_Cloud_Storage
        enable_actions_that_Terraform_service_account_has_been_granted_to_perform_on_the_API
        grant_the_service_account_permission_to_create_projects_and_assign_billing_accounts
        create_the_remote_backend_bucket_in_Cloud_Storage
        enable_versioning_for_remote_bucket
    else 
        link_it_to_your_billing_account
        create_service_account
        download_JSON_credentials
        grant_service_account_permission_to_view_the_Admin_Project_and_manage_Cloud_Storage
        enable_actions_that_Terraform_service_account_has_been_granted_to_perform_on_the_API
        grant_the_service_account_permission_to_create_projects_and_assign_billing_accounts
        create_the_remote_backend_bucket_in_Cloud_Storage
        if enable_versioning_for_remote_bucket
        then echo "kigaanye"
        else    

    fi
}

main "$@"
