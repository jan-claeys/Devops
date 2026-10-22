import 'package:devops/models/devops_link.dart';
import 'package:devops/models/pipeline_run.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const azure = 'https://dev.azure.com/contoso';
  ParsedLink? parse(String text, [String baseUrl = azure]) =>
      ParsedLink.parse(text, baseUrl: baseUrl);

  test('reads a work item link', () {
    expect(parse('https://dev.azure.com/contoso/Web%20Shop/_workitems/edit/123'),
        const DevOpsLink(DevOpsLinkKind.workItem, 123));
    expect(parse('https://dev.azure.com/contoso/_workitems/edit/7/'),
        const DevOpsLink(DevOpsLinkKind.workItem, 7));
  });

  test('reads a pull request link', () {
    expect(parse('https://dev.azure.com/contoso/Web%20Shop/_git/api/pullrequest/45?_a=files'),
        const DevOpsLink(DevOpsLinkKind.pullRequest, 45, project: 'Web Shop'));
    // A repository named after its project leaves the project out.
    expect(parse('https://dev.azure.com/contoso/_git/Shop/pullrequest/46'),
        const DevOpsLink(DevOpsLinkKind.pullRequest, 46, project: 'Shop'));
  });

  test('reads build and release links', () {
    final build = parse('https://dev.azure.com/contoso/Shop/_build/results?buildId=900&view=logs');
    expect(build, const DevOpsLink(DevOpsLinkKind.build, 900, project: 'Shop'));
    expect((build as DevOpsLink).runKind, RunKind.build);

    final release = parse('https://dev.azure.com/contoso/Shop/_releaseProgress'
        '?_a=release-pipeline-progress&releaseId=31');
    expect(release, const DevOpsLink(DevOpsLinkKind.release, 31, project: 'Shop'));
    expect((release as DevOpsLink).runKind, RunKind.release);
    expect(parse('https://dev.azure.com/contoso/Shop/_release?_a=release-summary&releaseId=32'),
        const DevOpsLink(DevOpsLinkKind.release, 32, project: 'Shop'));
  });

  test('finds the link in shared text', () {
    expect(parse('Bug 123: Checkout fails\nhttps://dev.azure.com/contoso/Shop/_workitems/edit/123'),
        const DevOpsLink(DevOpsLinkKind.workItem, 123));
  });

  test('treats visualstudio.com and dev.azure.com as the same organization', () {
    expect(parse('https://contoso.visualstudio.com/Shop/_workitems/edit/5'),
        const DevOpsLink(DevOpsLinkKind.workItem, 5));
    expect(parse('https://contoso.visualstudio.com/DefaultCollection/Shop/_git/api/pullrequest/6'),
        const DevOpsLink(DevOpsLinkKind.pullRequest, 6, project: 'Shop'));
    expect(parse('https://dev.azure.com/Contoso/Shop/_workitems/edit/5', 'https://contoso.visualstudio.com'),
        const DevOpsLink(DevOpsLinkKind.workItem, 5));
  });

  test('reads links of a server collection', () {
    const server = 'https://tfs.example.com/tfs/DefaultCollection';
    expect(parse('https://tfs.example.com/tfs/DefaultCollection/Shop/_workitems/edit/8', server),
        const DevOpsLink(DevOpsLinkKind.workItem, 8));
    expect(parse('https://tfs.example.com/tfs/Other/Shop/_workitems/edit/8', server),
        isA<ForeignLink>());
  });

  test('recognizes links of another organization', () {
    expect(parse('https://dev.azure.com/fabrikam/Shop/_workitems/edit/1'), isA<ForeignLink>());
    expect(parse('https://fabrikam.visualstudio.com/Shop/_workitems/edit/1'), isA<ForeignLink>());
  });

  test('ignores text without a link the app opens', () {
    expect(parse('no link here'), isNull);
    expect(parse('https://example.com/'), isNull);
    expect(parse('https://dev.azure.com/contoso/Shop/_git/api'), isNull);
    expect(parse('https://dev.azure.com/contoso/Shop/_workitems/edit/abc'), isNull);
    expect(parse('https://dev.azure.com/contoso/Shop/_build/results'), isNull);
    expect(parse('https://dev.azure.com/contoso/Shop/_boards/board/t/Shop%20Team/Stories'), isNull);
  });
}
