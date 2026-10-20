class Identity {
  const Identity({required this.displayName, this.uniqueName, this.imageUrl});

  final String displayName;
  final String? uniqueName;
  final String? imageUrl;

  static Identity? fromJson(Object? json) {
    if (json is Map<String, dynamic>) {
      return Identity(
        displayName: json['displayName'] as String? ?? '',
        uniqueName: json['uniqueName'] as String?,
        imageUrl: json['imageUrl'] as String?,
      );
    }
    if (json is String && json.isNotEmpty) {
      return Identity(displayName: json);
    }
    return null;
  }

  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class WorkItem {
  WorkItem({required this.id, required this.fields, this.relations = const []});

  final int id;
  final Map<String, dynamic> fields;
  final List<Map<String, dynamic>> relations;

  factory WorkItem.fromJson(Map<String, dynamic> json) => WorkItem(
        id: json['id'] as int,
        fields: (json['fields'] as Map<String, dynamic>?) ?? const {},
        relations: ((json['relations'] as List?) ?? const [])
            .cast<Map<String, dynamic>>(),
      );

  String get title => fields['System.Title'] as String? ?? '#$id';
  String get state => fields['System.State'] as String? ?? '';
  String get type => fields['System.WorkItemType'] as String? ?? '';
  String get project => fields['System.TeamProject'] as String? ?? '';
  String? get reason => fields['System.Reason'] as String?;
  String? get areaPath => fields['System.AreaPath'] as String?;
  String? get iterationPath => fields['System.IterationPath'] as String?;
  Identity? get assignedTo => Identity.fromJson(fields['System.AssignedTo']);
  Identity? get createdBy => Identity.fromJson(fields['System.CreatedBy']);
  DateTime? get createdDate => _date('System.CreatedDate');
  DateTime? get changedDate => _date('System.ChangedDate');
  int? get priority => (fields['Microsoft.VSTS.Common.Priority'] as num?)?.toInt();
  num? get storyPoints =>
      fields['Microsoft.VSTS.Scheduling.StoryPoints'] as num? ??
      fields['Microsoft.VSTS.Scheduling.Effort'] as num?;
  num? get originalEstimate =>
      fields['Microsoft.VSTS.Scheduling.OriginalEstimate'] as num?;
  num? get remainingWork =>
      fields['Microsoft.VSTS.Scheduling.RemainingWork'] as num?;
  num? get completedWork =>
      fields['Microsoft.VSTS.Scheduling.CompletedWork'] as num?;

  List<String> get tags {
    final raw = fields['System.Tags'] as String?;
    if (raw == null || raw.trim().isEmpty) return const [];
    return raw.split(';').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
  }

  String? get description => fields['System.Description'] as String?;
  String? get reproSteps => fields['Microsoft.VSTS.TCM.ReproSteps'] as String?;
  String? get acceptanceCriteria =>
      fields['Microsoft.VSTS.Common.AcceptanceCriteria'] as String?;

  /// Id of the parent work item, if any.
  int? get parentId {
    final parent = fields['System.Parent'];
    if (parent is num) return parent.toInt();
    for (final r in relations) {
      if (r['rel'] == 'System.LinkTypes.Hierarchy-Reverse') {
        return int.tryParse((r['url'] as String).split('/').last);
      }
    }
    return null;
  }

  /// Ids of child work items.
  List<int> get childIds => [
        for (final r in relations)
          if (r['rel'] == 'System.LinkTypes.Hierarchy-Forward')
            ?int.tryParse((r['url'] as String).split('/').last),
      ];

  DateTime? _date(String field) {
    final v = fields[field];
    return v is String ? DateTime.tryParse(v)?.toLocal() : null;
  }
}

class WorkItemComment {
  const WorkItemComment({
    required this.text,
    required this.createdBy,
    required this.createdDate,
  });

  final String text;
  final Identity? createdBy;
  final DateTime? createdDate;

  factory WorkItemComment.fromJson(Map<String, dynamic> json) => WorkItemComment(
        text: json['text'] as String? ?? '',
        createdBy: Identity.fromJson(json['createdBy']),
        createdDate:
            DateTime.tryParse(json['createdDate'] as String? ?? '')?.toLocal(),
      );
}

class Project {
  const Project({required this.id, required this.name, this.description});

  final String id;
  final String name;
  final String? description;

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
      );
}
