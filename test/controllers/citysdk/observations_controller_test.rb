# frozen_string_literal: true

require 'test_helper'

class ObservationsControllerTest < ActionDispatch::IntegrationTest
  test 'create without attributes' do
    post '/citysdk/observations.xml'
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '422', 'Gültigkeitsprüfung ist fehlgeschlagen'
  end

  test 'create with area_code but without categories' do
    post '/citysdk/observations.xml', params: { area_code: Authority.ids.join(',') }
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '422', 'Gültigkeitsprüfung ist fehlgeschlagen'
  end

  test 'create with area_code for all districts (separate) and all categories' do
    post '/citysdk/observations.xml', params: { area_code: -1,
                                                idea_service: MainCategory.kind_idea.ids.join(','),
                                                problem_service: MainCategory.kind_problem.ids.join(',') }
    doc = Nokogiri::XML(response.parsed_body)
    requests = doc.xpath('/observation/rss_id')
    assert_predicate requests.count, :positive?
  end

  test 'create with geometry and all categories' do
    post '/citysdk/observations.xml', params: { geometry: 'MULTIPOLYGON(((306803.3620605468 ' \
                                                          '6004727.578979492,306780.11022949213 ' \
                                                          '6002596.1611328125,308942.53051757807 ' \
                                                          '6003727.750244141,306803.3620605468 6004727.578979492)))',
                                                idea_service: MainCategory.kind_idea.ids.join(','),
                                                problem_service: MainCategory.kind_problem.ids.join(',') }
    doc = Nokogiri::XML(response.parsed_body)
    requests = doc.xpath('/observation/rss_id')
    assert_predicate requests.count, :positive?
  end

  test 'create with area_code for all districts (-1) and all categories' do
    post '/citysdk/observations.xml', params: { area_code: -1,
                                                idea_service: MainCategory.kind_idea.ids.join(','),
                                                problem_service: MainCategory.kind_problem.ids.join(',') }
    doc = Nokogiri::XML(response.parsed_body)
    requests = doc.xpath('/observation/rss_id')
    assert_predicate requests.count, :positive?
  end

  test 'create with area_code and all idea main categories' do
    post '/citysdk/observations.xml', params: { area_code: Authority.ids.join(','),
                                                idea_service: MainCategory.kind_idea.ids.join(',') }
    doc = Nokogiri::XML(response.parsed_body)
    requests = doc.xpath('/observation/rss_id')
    assert_predicate requests.count, :positive?
  end

  test 'create with area_code and all problem main categories' do
    post '/citysdk/observations.xml', params: { area_code: Authority.ids.join(','),
                                                problem_service: MainCategory.kind_problem.ids.join(',') }
    doc = Nokogiri::XML(response.parsed_body)
    requests = doc.xpath('/observation/rss_id')
    assert_predicate requests.count, :positive?
  end

  test 'create with area_code and all idea sub categories' do
    post '/citysdk/observations.xml',
      params: { area_code: Authority.ids.join(','),
                idea_service_sub: MainCategory.kind_idea.map { |x| x.sub_categories.ids }.flatten.join(',') }
    doc = Nokogiri::XML(response.parsed_body)
    requests = doc.xpath('/observation/rss_id')
    assert_predicate requests.count, :positive?
  end

  test 'create with area_code and all problem sub categories' do
    post '/citysdk/observations.xml',
      params: { area_code: Authority.ids.join(','),
                problem_service_sub: MainCategory.kind_problem.map { |x| x.sub_categories.ids }.flatten.join(',') }
    doc = Nokogiri::XML(response.parsed_body)
    requests = doc.xpath('/observation/rss_id')
    assert_predicate requests.count, :positive?
  end
end
