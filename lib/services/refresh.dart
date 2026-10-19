import 'package:flutter/foundation.dart';

/// Compteur global : chaque écran l'écoute pour se recharger
/// quand une dépense est ajoutée, modifiée ou supprimée.
final ValueNotifier<int> dataVersion = ValueNotifier<int>(0);

void notifyDataChanged() => dataVersion.value++;
