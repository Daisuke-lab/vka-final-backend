
source_code_hash = "${filebase64sha256("${data.archive_file.init_get_categories.source_file}")}"
"${base64sha256(file("${data.archive_file.init_get_categories.source_file}"))}"