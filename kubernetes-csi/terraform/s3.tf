resource "yandex_iam_service_account" "s3_access_sa" {
  name        = "s3-access-sa"
  description = "Service account for S3 bucket access"
}

resource "yandex_resourcemanager_folder_iam_member" "s3_access_sa_storage_editor" {
  folder_id = var.yc_folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.s3_access_sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "s3_access_sa" {
  service_account_id = yandex_iam_service_account.s3_access_sa.id
  description        = "Static access key for S3 bucket"
  depends_on         = [yandex_resourcemanager_folder_iam_member.s3_access_sa_storage_editor]
}

resource "yandex_storage_bucket" "csi" {
  bucket     = "${var.project_name}-csi"
  folder_id  = var.yc_folder_id
  access_key = yandex_iam_service_account_static_access_key.s3_access_sa.access_key
  secret_key = yandex_iam_service_account_static_access_key.s3_access_sa.secret_key

  anonymous_access_flags {
    read = false
    list = false
  }

  depends_on = [yandex_iam_service_account_static_access_key.s3_access_sa]
}
