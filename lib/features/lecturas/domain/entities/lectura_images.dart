class LecturaImage {
  final int id;
  final int lecturaId;
  final int usuarioId;
  final String path;
  final String? remoteId;
  final String syncState;
  final int updatedAt;

  LecturaImage({
    required this.id,
    required this.lecturaId,
    required this.usuarioId,
    required this.path,
    this.remoteId,
    required this.syncState,
    required this.updatedAt,
  });

  factory LecturaImage.fromMap(Map<String, dynamic> json) => LecturaImage(
        id: json['id'],
        lecturaId: json['lecturaId'],
        usuarioId: json['usuarioId'],
        path: json['path'],
        remoteId: json['remote_id'],
        syncState: json['sync_state'],
        updatedAt: json['updated_at'],
      );
}
