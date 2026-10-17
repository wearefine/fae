require 'rails_helper'

# fae_filter_frame: filtering, sorting and paging come from the query string and the server renders the state back,
# so a URL is the whole state of the page (and a Turbo frame can swap it in place).
describe 'filter frame on the index page' do
  let(:routes) { Rails.application.routes.url_helpers }
  let!(:events) { [FactoryBot.create(:event, name: 'Gala'), FactoryBot.create(:event, name: 'Tasting')] }

  before do
    admin_login
    %w[Alpha Bravo Charlie Delta Echo Foxtrot Golf].each_with_index do |name, i|
      FactoryBot.create(:person, name: name, event: events[i % 2], position: i + 1)
    end
  end

  def names
    response.body.scan(%r{<tr id="person_\d+">\s*<td><a [^>]*>([^<]+)</a>}).flatten
  end

  def frame
    response.body[%r{<turbo-frame.*?</turbo-frame>}m]
  end

  it 'wraps the form, table and pagination in a frame that leaves other links alone' do
    get routes.admin_people_path

    tag = response.body[/<turbo-frame[^>]*>/]
    expect(tag).to include('id="people_results"').and include('target="_top"').and include('data-controller="fae-frame-filter"')
    expect(frame).to include('<form').and include('<table').and include('class="pagination"')
  end

  it 'renders the filter form as a GET form that targets the frame' do
    get routes.admin_people_path

    form = response.body[/<form[^>]*>/]
    expect(form).to include('method="get"').and include('data-turbo-frame="people_results"')
    expect(form).not_to include('js-filter-form')
    expect(response.body).not_to match(/name="commit"/)
  end

  it 'pages without filter params exactly as before' do
    get routes.admin_people_path

    expect(names).to eq(%w[Alpha Bravo Charlie Delta Echo])

    get routes.admin_people_path(page: 2)
    expect(names).to eq(%w[Foxtrot Golf])
  end

  it 'filters by keyword and shows the keyword back in the form' do
    get routes.admin_people_path(filter: { search: 'o' })

    expect(names).to eq(%w[Bravo Echo Foxtrot Golf])
    expect(response.body).to match(/<input[^>]*name="filter\[search\]"[^>]*value="o"/)
  end

  it 'filters by a select and keeps it selected' do
    get routes.admin_people_path(filter: { event: events.last.id })

    expect(names).to eq(%w[Bravo Delta Foxtrot])
    expect(response.body).to include(%(<option selected="selected" value="#{events.last.id}">Tasting</option>))
  end

  it 'sorts and keeps the sort in the form so a filter change does not lose it' do
    get routes.admin_people_path(sort_by: 'name', sort_direction: 'desc')

    expect(names).to eq(%w[Golf Foxtrot Echo Delta Charlie])
    expect(response.body).to match(/<input[^>]*name="sort_by"[^>]*value="name"/)
    expect(response.body).to match(/<input[^>]*name="sort_direction"[^>]*value="desc"/)
  end

  it 'combines filtering and sorting' do
    get routes.admin_people_path(filter: { event: events.first.id }, sort_by: 'name', sort_direction: 'desc')

    expect(names).to eq(%w[Golf Echo Charlie Alpha])
  end

  it 'pages through sorted results' do
    get routes.admin_people_path(sort_by: 'name', sort_direction: 'desc', page: 2)

    expect(names).to eq(%w[Bravo Alpha])
  end

  it 'links pagination with the current filters and sort' do
    6.times { |i| FactoryBot.create(:person, name: "Zed #{i}", position: 100 + i) }
    get routes.admin_people_path(filter: { search: 'Zed' }, sort_by: 'name')

    link = response.body[%r{<a [^>]*href="([^"]*page=2[^"]*)"}, 1]
    expect(link).to include('filter%5Bsearch%5D=Zed').and include('sort_by=name')
  end

  context 'when nothing matches' do
    before { get routes.admin_people_path(filter: { search: 'zzz' }) }

    it 'still renders the form, with a visible reset link back to the unfiltered list' do
      expect(names).to be_empty
      expect(response.body).to include('No items found')
      expect(response.body).to match(/<form/)
      reset = response.body[/<a [^>]*js-frame-reset[^>]*>/]
      expect(reset).to include(%(href="#{routes.admin_people_path}")).and include('data-turbo-frame="people_results"')
    end
  end

  it 'only renders the reset link while a filter is active' do
    get routes.admin_people_path

    expect(response.body).not_to include('js-frame-reset')
  end
end
