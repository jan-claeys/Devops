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
  WorkItem({
    required this.id,
    required this.fields,
    this.relations = const [],
    this.markdownFields = const {},
  });

  final int id;
  final Map<String, dynamic> fields;
  final List<Map<String, dynamic>> relations;

  /// Multi-line fields that Azure DevOps stores as Markdown instead of HTML.
  final Set<String> markdownFields;

  static const descriptionField = 'System.Description';
  static const reproStepsField = 'Microsoft.VSTS.TCM.ReproSteps';
  static const acceptanceCriteriaField = 'Microsoft.VSTS.Common.AcceptanceCriteria';
  static const symptomField = 'Microsoft.VSTS.CMMI.Symptom';
  static const systemInfoField = 'Microsoft.VSTS.TCM.SystemInfo';
  static const proposedFixField = 'Microsoft.VSTS.CMMI.ProposedFix';

  factory WorkItem.fromJson(Map<String, dynamic> json) => WorkItem(
        id: json['id'] as int,
        fields: (json['fields'] as Map<String, dynamic>?) ?? const {},
        relations: ((json['relations'] as List?) ?? const [])
            .cast<Map<String, dynamic>>(),
        markdownFields: {
          for (final MapEntry(:key, :value)
              in ((json['multilineFieldsFormat'] as Map?) ?? const {}).entries)
            if ('$value'.toLowerCase() == 'markdown') key as String,
        },
      );

  bool isMarkdown(String field) => markdownFields.contains(field);

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

  String? get description => fields[descriptionField] as String?;
  String? get reproSteps => fields[reproStepsField] as String?;
  String? get acceptanceCriteria => fields[acceptanceCriteriaField] as String?;
  String? get symptom => fields[symptomField] as String?;
  String? get systemInfo => fields[systemInfoField] as String?;
  String? get proposedFix => fields[proposedFixField] as String?;
  bool get isBug => type == 'Bug';

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
    this.isMarkdown = false,
    this.mentions = const {},
  });

  final String text;
  final Identity? createdBy;
  final DateTime? createdDate;

  /// True when [text] is Markdown instead of HTML.
  final bool isMarkdown;

  /// Display names of the people mentioned as `@<guid>`, keyed by lowercase guid.
  final Map<String, String> mentions;

  factory WorkItemComment.fromJson(Map<String, dynamic> json) => WorkItemComment(
        text: json['text'] as String? ?? '',
        createdBy: Identity.fromJson(json['createdBy']),
        createdDate:
            DateTime.tryParse(json['createdDate'] as String? ?? '')?.toLocal(),
        isMarkdown: '${json['format']}'.toLowerCase() == 'markdown',
        mentions: _mentions(json['renderedText'] as String?),
      );

  /// Markdown comments only hold the guid of a mentioned person; the HTML
  /// that Azure DevOps renders from them carries the display name.
  static Map<String, String> _mentions(String? renderedText) => {
        for (final m in RegExp(
          r'''<a\b[^>]*data-vss-mention=["'][^"',]*,([0-9a-f-]+)["'][^>]*>@?(.*?)</a>''',
          caseSensitive: false,
          dotAll: true,
        ).allMatches(renderedText ?? ''))
          m[1]!.toLowerCase(): m[2]!,
      };
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
