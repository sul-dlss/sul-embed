module Constants
  FILE_ICON = {
    'application/msword' => 'sul-i-file-words',
    'application/pdf' => 'sul-i-file-acrobat',
    'application/vnd.ms-powerpointtd>' => 'sul-i-file-powerpoint',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation' => 'sul-i-file-powerpoint',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document' => 'sul-i-file-words',
    'application/vnd.ms-excel' => 'sul-i-file-excel',
    'application/x-compressed-zip' => 'sul-i-file-zipped',
    'application/x-gzip' => 'sul-i-file-zipped',
    'application/x-tar' => 'sul-i-file-zipped',
    'application/zip' => 'sul-i-file-zipped',
    'audio/mpeg' => 'sul-i-file-music-1',
    'image/gif' => 'sul-i-file-picture',
    'image/jp2' => 'sul-i-file-picture',
    'image/jpeg' => 'sul-i-file-picture',
    'image/png' => 'sul-i-file-picture',
    'text/plain' => 'sul-i-file-text-document',
    'text/x-c++' => 'sul-i-file-code',
    'video/avi' => 'sul-i-file-video-3',
    'video/mp4' => 'sul-i-file-video-3',
    'video/msvideo' => 'sul-i-file-video-3',
    'video/quicktime' => 'sul-i-file-video-3',
    'video/x-msvideo' => 'sul-i-file-video-3'
  }.freeze
  IMAGE_DOWNLOAD_SIZES = %w(
    default small medium large xlarge full).freeze
end
