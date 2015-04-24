RSpec.describe Grell::Page do

  let(:page_id) { rand(10).floor + 10}
  let(:parent_page_id) {rand(10).floor}
  let(:page) {Grell::Page.new(url, page_id, parent_page_id)}
  let(:host) {"http://www.example.com"}
  let(:url) {"http://www.example.com/test"}
  let(:returned_headers)  { { 'Other-Header' => 'yes', 'Content-Type' => 'text/html' }}

  it "gives access to the url" do
    expect(page.url).to eq(url)
  end

  it 'gives access to the path' do
    expect(page.path).to eq('/test')
  end

  it "gives access to the page id" do
    expect(page.id).to eq(page_id)
  end

  it "gives access to the parent page id" do
    expect(page.parent_id).to eq(parent_page_id)
  end

  shared_examples_for 'a grell page' do

    it 'returns the correct status' do
      expect(page.status).to eq(status)
    end

    it 'has the correct body' do
      expect(page.body).to eq(body)
    end

    it 'has correct headers' do
      expect(page.headers).to include(expected_headers)
    end

    it 'has the correct links' do
      expect(page.links).to eq(links)
    end

    it '#visited? returns the correct value' do
      expect(page.visited?).to eq(visited)
    end

  end

  context 'we have not yet navigated to the page' do
    let(:visited) {false}
    let(:status) {nil}
    let(:body) {''}
    let(:links) {[]}
    let(:expected_headers) {{}}

    before do
      proxy.stub(url).and_return(body: body, code: status, headers: returned_headers.dup)
    end

    it_behaves_like 'a grell page'

  end

  context 'navigating to the URL we get a 404' do
    let(:visited) {true}
    let(:status) { 404}
    let(:body) {'<html><head></head><body>nothing cool</body></html>'}
    let(:links) {[]}
    let(:expected_headers) {returned_headers}

    before do
      proxy.stub(url).and_return(body: body, code: status, headers: returned_headers.dup)
      page.navigate
    end

    it_behaves_like 'a grell page'

  end

  context 'navigating to the URL we get page with no links' do
    let(:visited) {true}
    let(:status) { 200}
    let(:body) {'<html><head></head><body>nothing cool</body></html>'}
    let(:links) {[]}
    let(:expected_headers) {returned_headers}

    before do
      proxy.stub(url).and_return(body: body, code: status, headers: returned_headers.dup)
      page.navigate
    end

    it_behaves_like 'a grell page'
  end

  context 'navigating to the URL we get page with links using a elements' do
    let(:visited) {true}
    let(:status) { 200}
    let(:body) do
      "<html><head></head><body>
      Hello world!
      <a href=\"/trusmis.html\">trusmis</a>
      <a href=\"/help.html\">help</a>
      <a href=\"http://www.outsidewebsite.com/help.html\">help</a>
      </body></html>"
    end
    let(:links) {["http://www.example.com/trusmis.html", "http://www.example.com/help.html"]}
    let(:expected_headers) {returned_headers}

    before do
      proxy.stub(url).and_return(body: body, code: status, headers: returned_headers.dup)
      page.navigate
    end

    it_behaves_like 'a grell page'

    it 'do not return links to external websites' do
      expect(page.links).to_not include('http://www.outsidewebsite.com/help.html')
    end
  end

  context 'navigating to the URL we get page with links with absolute links' do
    let(:visited) {true}
    let(:status) { 200}
    let(:body) do
      "<html><head></head><body>
      Hello world!
      <a href=\"/trusmis.html\">trusmis</a>
      <a href=\"http://www.example.com/help.html\">help</a>
      <a href=\"http://www.outsidewebsite.com/help.html\">help</a>
      </body></html>"
    end
    let(:links) {["http://www.example.com/trusmis.html", "http://www.example.com/help.html"]}
    let(:expected_headers) {returned_headers}

    before do
      proxy.stub(url).and_return(body: body, code: status, headers: returned_headers.dup)
      page.navigate
    end

    it_behaves_like 'a grell page'

    it 'do not return links to external websites' do
      expect(page.links).to_not include('http://www.outsidewebsite.com/help.html')
    end
  end

  context 'navigating to the URL we get page with links using a mix of elements' do
    let(:visited) {true}
    let(:status) { 200}
    let(:body) do
      "<html><head></head><body>
      Hello world!
      <a href=\"/trusmis.html\">trusmis</a>
      <table>
      <tbody>
      <tr href=\"/help.html\"><td>help</td></tr>
      <tr data-href=\"/help.html\"><td>help</td></tr>
      </tbody>
      </table>
      <div data-href=\"http://www.example.com/help.html\">help</div>
      <div data-href=\"http://www.outsidewebsite.com/help.html\">help</div>
      </body></html>"
    end
    let(:links) {["http://www.example.com/trusmis.html", "http://www.example.com/help.html"]}
    let(:expected_headers) {returned_headers}

    before do
      proxy.stub(url).and_return(body: body, code: status, headers: returned_headers.dup)
      page.navigate
    end

    it_behaves_like 'a grell page'

    it 'do not return links to external websites' do
      expect(page.links).to_not include('http://www.outsidewebsite.com/help.html')
    end
  end



end
