$('#issues-result').replaceWith("<%= j render(partial: 'issues_map') %>")
$('#issues-footer').replaceWith("<%= j render(partial: 'map_footer') %>")
KS.initializeMaps()
