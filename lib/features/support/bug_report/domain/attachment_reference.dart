class AttachmentReference {
  const AttachmentReference({
    required this.id,
    required this.fileName,
    required this.fileSizeBytes,
    required this.mimeType,
    required this.localPath,
    this.remoteStorageUrl,
  });

  final String id;
  final String fileName;
  final int fileSizeBytes;
  final String mimeType;
  final String localPath;
  final String? remoteStorageUrl;

  bool get isImage => mimeType.startsWith('image/');
  bool get isVideo => mimeType.startsWith('video/');

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'fileSizeBytes': fileSizeBytes,
      'mimeType': mimeType,
      'localPath': localPath,
      'remoteStorageUrl': remoteStorageUrl,
    };
  }

  factory AttachmentReference.fromJson(Map<String, dynamic> json) {
    return AttachmentReference(
      id: json['id'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      fileSizeBytes: (json['fileSizeBytes'] as num?)?.toInt() ?? 0,
      mimeType: json['mimeType'] as String? ?? 'application/octet-stream',
      localPath: json['localPath'] as String? ?? '',
      remoteStorageUrl: json['remoteStorageUrl'] as String?,
    );
  }
}
