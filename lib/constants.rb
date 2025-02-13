# frozen_string_literal: true

module Constants
  FILE_ICON = {
    'application/msword' => Icons::DescriptionComponent,
    'application/pdf' => Icons::PictureAsPdfComponent,
    'application/vnd.ms-powerpoint' => Icons::FilePresentComponent,
    'application/vnd.openxmlformats-officedocument.presentationml.presentation' => Icons::FilePresentComponent,
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document' => Icons::DescriptionComponent,
    'application/vnd.ms-excel' => Icons::InsertChartComponent,
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' => Icons::InsertChartComponent,
    'application/x-compressed-zip' => Icons::FolderZipComponent,
    'application/x-gzip' => Icons::FolderZipComponent,
    'application/x-tar' => Icons::FolderZipComponent,
    'application/zip' => Icons::FolderZipComponent,
    'audio/mpeg' => Icons::AudioFileComponent,
    'image/gif' => Icons::ImageComponent,
    'image/jp2' => Icons::ImageComponent,
    'image/jpeg' => Icons::ImageComponent,
    'image/png' => Icons::ImageComponent,
    'text/plain' => Icons::DescriptionComponent,
    'text/x-c++' => Icons::TerminalComponent,
    'video/avi' => Icons::VideoFileComponent,
    'video/mp4' => Icons::VideoFileComponent,
    'video/msvideo' => Icons::VideoFileComponent,
    'video/quicktime' => Icons::VideoFileComponent,
    'video/x-msvideo' => Icons::VideoFileComponent
  }.freeze

  IMAGE_DOWNLOAD_SIZES = %w[default small medium large xlarge full].freeze
end
