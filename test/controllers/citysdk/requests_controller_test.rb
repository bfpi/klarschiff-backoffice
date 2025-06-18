# frozen_string_literal: true

require 'test_helper'

class RequestsControllerTest < ActionDispatch::IntegrationTest
  test 'index without api-key' do
    get '/citysdk/requests.xml'
    doc = Nokogiri::XML(response.parsed_body)
    requests = doc.xpath('/service_requests/request')
    assert_predicate requests.count, :positive?
    extended_attributes = doc.xpath('/service_requests/request/extended_attributes')
    assert_predicate extended_attributes, :blank?
  end

  test 'index just_count without api-key' do
    get '/citysdk/requests.xml?just_count=true'
    doc = Nokogiri::XML(response.parsed_body)
    request_counts = doc.xpath('/service_requests/service_request/count')
    assert_equal 1, request_counts.count
    assert_predicate request_counts.text.to_i, :positive?
  end

  test 'index with invalid api-key' do
    get "/citysdk/requests.xml?api_key=#{api_key_invalid}"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '401', 'Der übergebene API-Key ist ungültig.'
  end

  test 'index with api-key frontend' do
    get "/citysdk/requests.xml?api_key=#{api_key_frontend}"
    doc = Nokogiri::XML(response.parsed_body)
    requests = doc.xpath('/service_requests/request')
    assert_predicate requests.count, :positive?
    extended_attributes = doc.xpath('/service_requests/request/extended_attributes')
    assert_predicate extended_attributes, :blank?
  end

  test 'index with api-key ppc' do
    get "/citysdk/requests.xml?api_key=#{api_key_ppc}"
    doc = Nokogiri::XML(response.parsed_body)
    extended_attributes = doc.xpath('/service_requests/request/extended_attributes')
    assert_predicate extended_attributes, :blank?
  end

  test 'index with extensions without api-key' do
    get '/citysdk/requests.xml?extensions=true'
    doc = Nokogiri::XML(response.parsed_body)
    requests = doc.xpath('/service_requests/request')
    assert_predicate requests.count, :positive?
    extended_attributes = doc.xpath('/service_requests/request/extended_attributes')
    assert_predicate extended_attributes.count, :positive?
    extended_attributes = doc.xpath('/service_requests/request/extended_attributes/property_owner')
    assert_predicate extended_attributes, :blank?
  end

  test 'index with extensions with invalid api-key' do
    get "/citysdk/requests.xml?extensions=true&api_key=#{api_key_invalid}"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '401', 'Der übergebene API-Key ist ungültig.'
  end

  test 'index with extensions with api-key frontend' do
    get "/citysdk/requests.xml?extensions=true&api_key=#{api_key_frontend}"
    doc = Nokogiri::XML(response.parsed_body)
    requests = doc.xpath('/service_requests/request')
    assert_predicate requests.count, :positive?
    extended_attributes = doc.xpath('/service_requests/request/extended_attributes')
    assert_predicate extended_attributes.count, :positive?
    extended_attributes = doc.xpath('/service_requests/request/extended_attributes/property_owner')
    assert_predicate extended_attributes, :blank?
  end

  test 'index with extensions and area_code for authorities with api-key frontend' do
    with_parent_instance_settings do
      get "/citysdk/requests.xml?extensions=true&area_code=#{authority(:one).id}&api_key=#{api_key_frontend}"
      doc = Nokogiri::XML(response.parsed_body)
      requests = doc.xpath('/service_requests/request')
      assert_predicate requests.count, :positive?
    end
  end

  test 'index with extensions and area_code for districts with api-key frontend' do
    with_parent_instance_settings(url: 'http://www.example.com') do
      get "/citysdk/requests.xml?extensions=true&area_code=#{district(:one).id}&api_key=#{api_key_frontend}"
      doc = Nokogiri::XML(response.parsed_body)
      requests = doc.xpath('/service_requests/request')
      assert_predicate requests.count, :positive?
    end
  end

  test 'index with observation-key' do
    get "/citysdk/requests.xml?observation_key=#{observation(:one).key}"
    doc = Nokogiri::XML(response.parsed_body)
    requests = doc.xpath('/service_requests/request')
    assert_predicate requests.count, :positive?
  end

  test 'index with unknown observation-key' do
    get '/citysdk/requests.xml?observation_key=1234'
    doc = Nokogiri::XML(response.parsed_body)
    requests = doc.xpath('/service_requests/request')
    assert_predicate requests.count, :zero?
  end

  test 'index with extensions with api-key ppc' do
    get "/citysdk/requests.xml?extensions=true&api_key=#{api_key_ppc}"
    doc = Nokogiri::XML(response.parsed_body)
    extended_attributes = doc.xpath('/service_requests/request/extended_attributes/property_owner')
    assert_predicate extended_attributes.count, :positive?
  end

  %i[idea problem].each do |kind|
    test "index with keyword filter #{kind}" do
      get "/citysdk/requests.json?extensions=true&api_key=#{api_key_frontend}&keyword=#{kind}"
      assert_response :success
      assert_not_empty(list = response.parsed_body)
      assert(list.all? { |issue| Issue.find(issue['service_request_id']).kind == kind.to_s })
    end
  end

  test 'index with keyword filter list' do
    keywords = %w[idea problem]
    get "/citysdk/requests.json?extensions=true&api_key=#{api_key_frontend}&keyword=#{keywords.join ','}"
    assert_response :success
    assert_not_empty(list = response.parsed_body)
    assert(list.all? { |issue| Issue.find(issue['service_request_id']).kind.in? keywords })
  end

  test 'reject index with keyword tip for unpermitted clients' do
    get "/citysdk/requests.json?extensions=true&api_key=#{api_key_frontend}&keyword=tip"
    assert_response :error
    assert_equal 'keyword invalid', response.parsed_body.first['description']
  end

  test 'index with keyword tip for permitted clients' do
    get "/citysdk/requests.json?extensions=true&api_key=#{api_key_ppc}&keyword=tip"
    assert_response :success
    assert_not_empty(list = response.parsed_body)
    assert(list.all? { |issue| Issue.find(issue['service_request_id']).kind == 'tip' })
  end

  test 'index with invalid keyword filter' do
    get "/citysdk/requests.json?extensions=true&api_key=#{api_key_frontend}&keyword=test"
    assert_response :error
    assert_equal 'keyword invalid', response.parsed_body.first['description']
  end

  test 'show without api-key' do
    get "/citysdk/requests/#{issue(:one).id}.xml"
    doc = Nokogiri::XML(response.parsed_body)
    requests = doc.xpath('/service_requests/request')
    assert_predicate requests.count, :positive?
    extended_attributes = doc.xpath('/service_requests/request/extended_attributes')
    assert_predicate extended_attributes, :blank?
    assert_empty doc.xpath('/service_requests/request/create_message')
  end

  test 'show with api-key frontend' do
    get "/citysdk/requests/#{issue(:one).id}.xml?api_key=#{api_key_frontend}"
    doc = Nokogiri::XML(response.parsed_body)
    requests = doc.xpath('/service_requests/request')
    assert_predicate requests.count, :positive?
    extended_attributes = doc.xpath('/service_requests/request/extended_attributes')
    assert_predicate extended_attributes, :blank?
  end

  test 'show with api-key ppc' do
    get "/citysdk/requests/#{issue(:one).id}.xml?api_key=#{api_key_ppc}"
    doc = Nokogiri::XML(response.parsed_body)
    extended_attributes = doc.xpath('/service_requests/request/extended_attributes')
    assert_predicate extended_attributes, :blank?
  end

  test 'show with extensions without api-key' do
    get "/citysdk/requests/#{issue(:one).id}.xml?extensions=true"
    doc = Nokogiri::XML(response.parsed_body)
    requests = doc.xpath('/service_requests/request')
    assert_predicate requests.count, :positive?
    extended_attributes = doc.xpath('/service_requests/request/extended_attributes')
    assert_predicate extended_attributes.count, :positive?
    extended_attributes = doc.xpath('/service_requests/request/extended_attributes/property_owner')
    assert_predicate extended_attributes, :blank?
  end

  test 'show with extensions with api-key frontend' do
    get "/citysdk/requests/#{issue(:one).id}.xml?extensions=true&api_key=#{api_key_frontend}"
    doc = Nokogiri::XML(response.parsed_body)
    requests = doc.xpath('/service_requests/request')
    assert_predicate requests.count, :positive?
    extended_attributes = doc.xpath('/service_requests/request/extended_attributes')
    assert_predicate extended_attributes.count, :positive?
    extended_attributes = doc.xpath('/service_requests/request/extended_attributes/property_owner')
    assert_predicate extended_attributes, :blank?
  end

  test 'show with extensions with api-key ppc' do
    get "/citysdk/requests/#{issue(:one).id}.xml?extensions=true&api_key=#{api_key_ppc}"
    doc = Nokogiri::XML(response.parsed_body)
    extended_attributes = doc.xpath('/service_requests/request/extended_attributes/property_owner')
    assert_predicate extended_attributes.count, :positive?
  end

  test 'create without api-key' do
    post '/citysdk/requests.xml'
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '400', 'Es wurde kein API-Key übergeben.'
  end

  test 'create with invalid api-key' do
    post "/citysdk/requests.xml?api_key=#{api_key_invalid}"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '401', 'Der übergebene API-Key ist ungültig.'
  end

  test 'create with frontend api-key but without attributes' do
    post "/citysdk/requests.xml?api_key=#{api_key_frontend}"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '422', 'Gültigkeitsprüfung ist fehlgeschlagen'
  end

  test 'create with frontend api-key' do
    post "/citysdk/requests.xml?api_key=#{api_key_frontend}", params: valid_create_params
    doc = Nokogiri::XML(response.parsed_body)
    service_request_id = doc.xpath('/service_requests/request/service_request_id')
    assert_not_empty doc.xpath('/service_requests/request/create_message')
    assert_equal 1, service_request_id.count
    assert issue = Issue.find(service_request_id.first.text)
    assert_enqueued_emails 1
    assert_enqueued_email_with(
      ConfirmationMailer, :issue,
      args: [{ to: 'test@example.com', confirmation_hash: issue.confirmation_hash, issue_id: issue.id,
               with_photo: false }]
    )
  end

  test 'create with frontend api-key but geocodr returns forbidden' do
    OpenURI.stub :open_uri, ->(_a, _b) { raise OpenURI::HTTPError.new(403, 'FORBIDDEN') } do
      post "/citysdk/requests.xml?api_key=#{api_key_frontend}", params: valid_create_params
      doc = Nokogiri::XML(response.parsed_body)
      service_request_id = doc.xpath('/service_requests/request/service_request_id')
      assert_not_empty doc.xpath('/service_requests/request/create_message')
      assert_equal 1, service_request_id.count
      assert issue = Issue.find(service_request_id.first.text)
      assert_enqueued_emails 1
      assert_enqueued_email_with(
        ConfirmationMailer, :issue,
        args: [{ to: 'test@example.com', confirmation_hash: issue.confirmation_hash, issue_id: issue.id,
                 with_photo: false }]
      )
    end
  end

  test 'create with frontend api-key but geocodr is not available' do
    OpenURI.stub :open_uri, ->(_a, _b) { raise OpenURI::HTTPError.new(500, 'INTERNAL SERVER ERROR') } do
      post "/citysdk/requests.xml?api_key=#{api_key_frontend}", params: valid_create_params
      doc = Nokogiri::XML(response.parsed_body)
      service_request_id = doc.xpath('/service_requests/request/service_request_id')
      assert_not_empty doc.xpath('/service_requests/request/create_message')
      assert_equal 1, service_request_id.count
      assert issue = Issue.find(service_request_id.first.text)
      assert_enqueued_emails 1
      assert_enqueued_email_with(
        ConfirmationMailer, :issue,
        args: [{ to: 'test@example.com', confirmation_hash: issue.confirmation_hash, issue_id: issue.id,
                 with_photo: false }]
      )
    end
  end

  test 'reject create without privacy_policy_accepted if required' do
    with_privacy_settings(active: true) do
      post "/citysdk/requests.xml?api_key=#{api_key_frontend}", params: valid_create_params
      doc = Nokogiri::XML(response.parsed_body)
      assert_error_messages doc, '422', 'Gültigkeitsprüfung ist fehlgeschlagen'
    end
  end

  test 'create with frontend api-key and photo' do
    post "/citysdk/requests.xml?api_key=#{api_key_frontend}", params: valid_create_params.merge(
      media: Base64.encode64(Rails.root.join('test/fixtures/files/test.jpg').read)
    )
    doc = Nokogiri::XML(response.parsed_body)
    service_request_id = doc.xpath('/service_requests/request/service_request_id')
    assert_equal 1, service_request_id.count
    assert issue = Issue.find(service_request_id.first.text)
    assert_enqueued_emails 1
    assert_enqueued_email_with(
      ConfirmationMailer, :issue,
      args: [{ to: 'test@example.com', confirmation_hash: issue.confirmation_hash, issue_id: issue.id,
               with_photo: true }]
    )
    assert_enqueued_jobs 1, only: ActiveStorage::AnalyzeJob
  end

  test 'update without api-key' do
    put "/citysdk/requests/#{issue(:one).id}.xml"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '400', 'Es wurde kein API-Key übergeben.'
  end

  test 'update with invalid api-key' do
    put "/citysdk/requests/#{issue(:one).id}.xml?api_key=#{api_key_invalid}"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '401', 'Der übergebene API-Key ist ungültig.'
  end

  test 'update with frontend api-key but without permissions' do
    put "/citysdk/requests/#{issue(:one).id}.xml?api_key=#{api_key_frontend}"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '403',
      'Mit dem übergebenen API-Key stehen die benötigten Zugriffsrechte nicht zur Verfügung.'
  end

  test 'update with frontend api-key but without attributes' do
    put "/citysdk/requests/#{issue(:one).id}.xml?api_key=#{api_key_ppc}"
    doc = Nokogiri::XML(response.parsed_body)
    service_request_id = doc.xpath('/service_requests/request/service_request_id')
    assert_equal 1, service_request_id.count
  end

  test 'update with ppc api-key' do
    put "/citysdk/requests/#{issue(:one).id}.xml?api_key=#{api_key_ppc}", params: valid_update_params
    doc = Nokogiri::XML(response.parsed_body)
    service_request_id = doc.xpath('/service_requests/request/service_request_id')
    assert_equal 1, service_request_id.count
  end

  test 'update attribute service_code with ppc api-key' do
    new_value = category(:two).id
    reloaded_request = update_request_and_reload(issue(:one).id, :service_code, new_value)
    assert_equal new_value.to_s, reloaded_request.xpath('/service_requests/request/service_code/text()').first.to_s
  end

  test 'update attribute description with ppc api-key' do
    new_value = 'Lorem ipsum dolor sit amet'
    reloaded_request = update_request_and_reload(issue(:one).id, :description, new_value)
    assert_equal new_value.to_s, reloaded_request.xpath('/service_requests/request/description/text()').first.to_s
  end

  test 'update attribute address_string with ppc api-key' do
    new_value = 'Holbeinplatz 14, 18069 Rostock'
    ::Geocodr.stub :request_and_parse_features,
      JSON.parse(File.read('test/fixtures/files/geocodr.json')).try(:[], 'features') do
      reloaded_request = update_request_and_reload(issue(:one).id, :address_string, new_value)
      assert_equal 'Holbeinplatz 14 (Reutershagen)',
        reloaded_request.xpath('/service_requests/request/address/text()').first.to_s
    end
  end

  test 'update attribute address_string but geocodr is not available' do
    new_value = 'Holbeinplatz 14, 18069 Rostock'

    OpenURI.stub :open_uri, ->(_a, _b) { raise OpenURI::HTTPError.new(500, 'INTERNAL SERVER ERROR') } do
      put "/citysdk/requests/#{issue(:one).id}.xml?api_key=#{api_key_ppc}", params: { address_string: new_value }
      doc = Nokogiri::XML(response.parsed_body)
      assert_error_messages doc, '422', 'Gültigkeitsprüfung ist fehlgeschlagen'
    end
  end

  test 'update attribute photo_required with ppc api-key' do
    reloaded_request = update_request_and_reload(issue(:one).id, :photo_required, 'true')
    assert_equal 'true', reloaded_request
      .xpath('/service_requests/request/extended_attributes/photo_required/text()').first.to_s
  end

  test 'update attribute media with ppc api-key' do
    reloaded_request = update_request_and_reload(issue(:one).id, :media,
      Base64.encode64(File.read('test/fixtures/files/test.jpg')), email: user(:one).email)
    assert_not_empty reloaded_request.xpath('/service_requests/request/media_url/text()').first.to_s
  end

  test 'update attribute detailed_status with ppc api-key' do
    new_value = 'IN_PROCESS'
    reloaded_request = update_request_and_reload(issue(:one).id, :detailed_status, new_value)
    assert_equal new_value,
      reloaded_request.xpath('/service_requests/request/extended_attributes/detailed_status/text()').first.to_s
  end

  test 'update attribute invalid detailed_status with ppc api-key' do
    put "/citysdk/requests/#{issue(:one).id}.xml?api_key=#{api_key_ppc}", params: { detailed_status: 'ABCDE' }
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '500', 'status invalid'
  end

  test 'update attribute status_notes with ppc api-key' do
    new_value = 'consetetur sadipscing elitr, sed diam'
    reloaded_request = update_request_and_reload(issue(:one).id, :status_notes, new_value)
    assert_equal new_value, reloaded_request.xpath('/service_requests/request/status_notes/text()').first.to_s
  end

  test 'update attribute priority with ppc api-key' do
    new_value = '2'
    reloaded_request = update_request_and_reload(issue(:one).id, :priority, new_value)
    assert_equal new_value,
      reloaded_request.xpath('/service_requests/request/extended_attributes/priority/text()').first.to_s
  end

  test 'update attribute invalid priority with ppc api-key' do
    put "/citysdk/requests/#{issue(:one).id}.xml?api_key=#{api_key_ppc}", params: { priority: '5' }
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '422', 'Gültigkeitsprüfung ist fehlgeschlagen'
  end

  test 'update attribute delegation with ppc api-key' do
    new_value = group(:external).short_name
    reloaded_request = update_request_and_reload(issue(:one).id, :delegation, new_value)
    assert_equal new_value,
      reloaded_request.xpath('/service_requests/request/extended_attributes/delegation/text()').first.to_s
  end

  test 'update attribute delegation to internal group with ppc api-key' do
    put "/citysdk/requests/#{issue(:one).id}.xml?api_key=#{api_key_ppc}", params: { delegation: group(:one).name }
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '422', 'Gültigkeitsprüfung ist fehlgeschlagen'
  end

  test 'update attribute delegation to invalid group with ppc api-key' do
    put "/citysdk/requests/#{issue(:one).id}.xml?api_key=#{api_key_ppc}", params: { delegation: 'abcdefgh' }
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '422', 'Gültigkeitsprüfung ist fehlgeschlagen'
  end

  test 'update attribute job_status with ppc api-key' do
    new_value = 'CHECKED'
    reloaded_request = update_request_and_reload(issue(:one).id, :job_status, new_value)
    assert_equal new_value,
      reloaded_request.xpath('/service_requests/request/extended_attributes/job_status/text()').first.to_s
  end

  test 'update attribute invalid job_status with ppc api-key' do
    put "/citysdk/requests/#{issue(:one).id}.xml?api_key=#{api_key_ppc}", params: { job_status: 'ABCDE' }
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '422', 'Gültigkeitsprüfung ist fehlgeschlagen'
  end

  test 'update attribute detailed_status as rejected with ppc api-key' do
    issue = issue(:in_process)
    new_value = 'REJECTED'
    reloaded_request = update_request_and_reload(issue.id, :detailed_status, new_value)
    assert_equal 'not_solvable', issue.reload.status
    assert_equal new_value,
      reloaded_request.xpath('/service_requests/request/extended_attributes/detailed_status/text()').first.to_s
  end

  test 'update attribute job_priority with ppc api-key' do
    new_value = '4'
    reloaded_request = update_request_and_reload(issue(:one).id, :job_priority, new_value)
    assert_equal new_value,
      reloaded_request.xpath('/service_requests/request/extended_attributes/job_priority/text()').first.to_s
  end

  test 'confirm' do
    put "/citysdk/requests/#{issue(:unconfirmed).confirmation_hash}/confirm.xml"
    doc = Nokogiri::XML(response.parsed_body)
    assert_equal 1, doc.xpath('/service_requests/request/service_request_id').count
  end

  test 'confirm already confirmed hash' do
    put "/citysdk/requests/#{issue(:already_confirmed).confirmation_hash}/confirm.xml"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '404', 'record_not_found'
  end

  test 'confirm invalid hash' do
    put '/citysdk/requests/abcdefghijklmnopqrstuvwxyz/confirm.xml'
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '404', 'record_not_found'
  end

  test 'delete without api-key' do
    put "/citysdk/requests/#{issue(:one).confirmation_hash}/revoke.xml"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '404', 'record_not_found'
  end

  test 'delete with invalid api-key' do
    put "/citysdk/requests/#{issue(:one).confirmation_hash}/revoke.xml?api_key=#{api_key_invalid}"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '401', 'Der übergebene API-Key ist ungültig.'
  end

  test 'delete successfully with ppc api-key' do
    put "/citysdk/requests/#{issue(:deleteable).confirmation_hash}/revoke.xml?api_key=#{api_key_ppc}"
    doc = Nokogiri::XML(response.parsed_body)
    service_request_id = doc.xpath('/service_requests/request/service_request_id')
    assert_equal 1, service_request_id.count
  end

  test 'deletion cancellation due to existing supporter with ppc api-key' do
    put "/citysdk/requests/#{issue(:undeleteable_supporter).confirmation_hash}/revoke.xml?api_key=#{api_key_ppc}"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '404', 'record_not_found'
  end

  test 'deletion cancellation due to existing abuse_report with ppc api-key' do
    put "/citysdk/requests/#{issue(:undeleteable_abuse_report).confirmation_hash}/revoke.xml?api_key=#{api_key_ppc}"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '404', 'record_not_found'
  end

  test 'deletion cancellation due to invalid status with ppc api-key' do
    put "/citysdk/requests/#{issue(:undeleteable_status).confirmation_hash}/revoke.xml?api_key=#{api_key_ppc}"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '404', 'record_not_found'
  end

  test 'description text for issues' do
    request = issue(:one)
    get "/citysdk/requests/#{request.id}.xml"
    doc = Nokogiri::XML(response.parsed_body)
    assert_equal request.description, doc.xpath('/service_requests/request/description/text()').first.to_s
  end

  test 'description text for issues on authority default groups' do
    with_gui_access_for_external_participants(value: false) do
      get "/citysdk/requests/#{issue(:reference_default).id}.xml"
      doc = Nokogiri::XML(response.parsed_body)
      assert_equal I18n.t('request.description.default_group'),
        doc.xpath('/service_requests/request/description/text()').first.to_s
    end
  end

  test 'description text for issues on county default groups' do
    with_gui_access_for_external_participants(value: false) do
      get "/citysdk/requests/#{issue(:reference_default_county).id}.xml"
      doc = Nokogiri::XML(response.parsed_body)
      assert_equal I18n.t('request.description.default_group_countygroup'),
        doc.xpath('/service_requests/request/description/text()').first.to_s
    end
  end

  private

  def valid_create_params
    {
      email: 'test@example.com', service_code: category(:two).id, description: 'Lorem ipsum dolor sit amet',
      lat: 54.09104309547743, long: 12.122439338030057, photo_required: true
    }
  end

  def valid_update_params
    valid_create_params.merge(detailed_status: 'IN_PROCESS', status_notes: 'consetetur sadipscing elitr, sed diam',
      priority: 2, delegation: group(:external).short_name, job_status: 'CHECKED',
      job_priority: 1)
  end

  def update_request_and_reload(request_id, attr, value, additional_params = {})
    put "/citysdk/requests/#{request_id}.xml?api_key=#{api_key_ppc}", params: { attr => value }.merge(additional_params)
    doc = Nokogiri::XML(response.parsed_body)
    service_request_id = doc.xpath('/service_requests/request/service_request_id')
    assert_equal 1, service_request_id.count
    get "/citysdk/requests/#{request_id}.xml?extensions=true&api_key=#{api_key_ppc}"
    Nokogiri::XML(response.parsed_body)
  end
end
