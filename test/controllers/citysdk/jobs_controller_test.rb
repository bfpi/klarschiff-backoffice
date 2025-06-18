# frozen_string_literal: true

require 'test_helper'

class JobsControllerTest < ActionDispatch::IntegrationTest
  test 'index without api-key' do
    get '/citysdk/jobs.xml'
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '400', 'Es wurde kein API-Key übergeben.'
  end

  test 'index with api-key frontend' do
    get "/citysdk/jobs.xml?api_key=#{api_key_frontend}"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '403',
      'Mit dem übergebenen API-Key stehen die benötigten Zugriffsrechte nicht zur Verfügung.'
  end

  test 'index with api-key ppc but without attributes' do
    get "/citysdk/jobs.xml?api_key=#{api_key_ppc}"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '422', 'Es wurde kein Datum übergeben.'
  end

  test 'index with api-key ppc' do
    get "/citysdk/jobs.xml?api_key=#{api_key_ppc}&date=#{Time.zone.today}"
    doc = Nokogiri::XML(response.parsed_body)
    jobs = doc.xpath('/jobs/job/id')
    assert_equal Job.count, jobs.count
  end

  test 'index with api-key ppci with given status' do
    get "/citysdk/jobs.xml?api_key=#{api_key_ppc}&date=#{Time.zone.today}&status=unchecked"
    doc = Nokogiri::XML(response.parsed_body)
    jobs = doc.xpath('/jobs/job/id')
    assert_equal Job.status_unchecked.count, jobs.count
  end

  test 'create without api-key' do
    post '/citysdk/jobs.xml'
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '400', 'Es wurde kein API-Key übergeben.'
  end

  test 'create with api-key frontend' do
    post "/citysdk/jobs.xml?api_key=#{api_key_frontend}"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '403',
      'Mit dem übergebenen API-Key stehen die benötigten Zugriffsrechte nicht zur Verfügung.'
  end

  test 'create with api-key ppc but without attributes' do
    post "/citysdk/jobs.xml?api_key=#{api_key_ppc}"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '422', 'Gültigkeitsprüfung ist fehlgeschlagen'
  end

  test 'create without service_request_id' do
    post '/citysdk/jobs.xml', params: { api_key: api_key_ppc,
                                        agency_responsible: group(:field_service).short_name,
                                        date: Time.zone.today.to_s }
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '404', 'record_not_found'
  end

  test 'create without agency_responsible' do
    post '/citysdk/jobs.xml', params: { api_key: api_key_ppc, service_request_id: issue(:in_process).id,
                                        date: Time.zone.today.to_s }
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '422', 'Gültigkeitsprüfung ist fehlgeschlagen'
  end

  test 'create with invalid agency_responsible' do
    post '/citysdk/jobs.xml', params: { api_key: api_key_ppc, service_request_id: issue(:in_process).id,
                                        agency_responsible: 'ABCDEFG',
                                        date: Time.zone.today.to_s }
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '422', 'Gültigkeitsprüfung ist fehlgeschlagen'
  end

  test 'create without date' do
    post '/citysdk/jobs.xml', params: { api_key: api_key_ppc, service_request_id: issue(:in_process).id,
                                        agency_responsible: group(:field_service).short_name }
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '422', 'Gültigkeitsprüfung ist fehlgeschlagen'
  end

  test 'create' do
    post '/citysdk/jobs.xml', params: { api_key: api_key_ppc, service_request_id: issue(:in_process).id,
                                        agency_responsible: group(:field_service).short_name,
                                        date: Time.zone.today.to_s }
    doc = Nokogiri::XML(response.parsed_body)
    assert_equal 1, doc.xpath('/jobs/job/id').count
  end

  test 'update without api-key' do
    put "/citysdk/jobs/#{issue(:in_process).id}.xml"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '400', 'Es wurde kein API-Key übergeben.'
  end

  test 'update with api-key frontend' do
    put "/citysdk/jobs/#{issue(:in_process).id}.xml", params: { api_key: api_key_frontend }
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '403',
      'Mit dem übergebenen API-Key stehen die benötigten Zugriffsrechte nicht zur Verfügung.'
  end

  test 'update with api-key ppc but invalid issue' do
    put "/citysdk/jobs/#{issue(:in_process).id}.xml", params: { api_key: api_key_ppc }
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '404', 'record_not_found'
  end

  test 'update with api-key ppc but without attributes' do
    put "/citysdk/jobs/#{issue(:one).id}.xml", params: { api_key: api_key_ppc }
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '422', 'Gültigkeitsprüfung ist fehlgeschlagen'
  end

  test 'update without status' do
    put "/citysdk/jobs/#{issue(:one).id}.xml", params: { api_key: api_key_ppc,
                                                         date: Time.zone.today.to_s }
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '422', 'Gültigkeitsprüfung ist fehlgeschlagen'
  end

  test 'update with invalid status' do
    put "/citysdk/jobs/#{issue(:one).id}.xml", params: { api_key: api_key_ppc,
                                                         status: 'ABCDEFG',
                                                         date: Time.zone.today.to_s }
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '500', 'is not a valid status'
  end

  test 'update without date' do
    put "/citysdk/jobs/#{issue(:one).id}.xml", params: { api_key: api_key_ppc,
                                                         status: 'CHECKED' }
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '422', 'Gültigkeitsprüfung ist fehlgeschlagen'
  end

  test 'update' do
    put "/citysdk/jobs/#{issue(:one).id}.xml", params: { api_key: api_key_ppc,
                                                         status: 'CHECKED',
                                                         date: Time.zone.today.to_s }
    doc = Nokogiri::XML(response.parsed_body)
    assert_equal 1, doc.xpath('/jobs/job/id').count
  end
end
