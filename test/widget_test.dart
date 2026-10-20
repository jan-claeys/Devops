import 'package:devops_tickets/services/devops_api.dart';
import 'package:devops_tickets/widgets/work_item_visuals.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizeOrganization accepts several formats', () {
    expect(DevOpsApi.normalizeOrganization('aucxis'), 'https://dev.azure.com/aucxis');
    expect(DevOpsApi.normalizeOrganization('dev.azure.com/aucxis/'),
        'https://dev.azure.com/aucxis');
    expect(DevOpsApi.normalizeOrganization('https://aucxis.visualstudio.com'),
        'https://aucxis.visualstudio.com');
  });

  test('htmlToText strips markup', () {
    expect(htmlToText('<div>Hallo&nbsp;<b>wereld</b></div><ul><li>een</li><li>twee</li></ul>'),
        'Hallo wereld\n\n• een\n• twee');
  });
}
