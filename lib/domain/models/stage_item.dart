
class StageItem {
  final String id;
  final String title;
  final String subtitle;
  final bool required;
  final bool completed;

  const StageItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.required,
    required this.completed,
  });

  StageItem copyWith({bool? completed}) => StageItem(
    id: id,
    title: title,
    subtitle: subtitle,
    required: required,
    completed: completed ?? this.completed,
  );
}
