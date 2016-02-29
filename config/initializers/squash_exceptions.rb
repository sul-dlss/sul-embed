Squash::Ruby.configure api_host: Settings.squash_api_host,
                       api_key: Settings.squash_api_key,
                       environment: Settings.squash_environment || Rails.env,
                       disabled: Settings.squash_disable,
                       revision_file: File.join(Rails.root, 'REVISION')
