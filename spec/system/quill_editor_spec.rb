# frozen_string_literal: true

RSpec.describe 'Quill editor', type: :system do
  let(:author) { Author.create!(email: 'some_email@example.com', name: 'John Doe', age: 30) }
  let(:post) { Post.create!(title: 'Test', author: author, description: 'Some content...') }

  before do
    post
  end

  after do
    Post.destroy_all
    author.destroy
  end

  context 'with a Quill editor' do
    it 'updates some HTML content' do
      visit "/admin/posts/#{post.id}/edit"

      %w[bold italic underline link].each do |button|
        expect(page).to have_css(".ql-toolbar button.ql-#{button}")
      end
      expect(page).to have_css('#post_description[data-aa-quill-editor]')
      expect(page).to have_css('#post_description_input .ql-editor', text: 'Some content...')
      find('#post_description_input .ql-editor').click
      find('#post_description_input .ql-editor').base.send_keys('more text')

      find('[type="submit"]').click
      expect(page).to have_content('was successfully updated')
      expect(post.reload.description).to eq '<p>Some content...more text</p>'
    end
  end

  context 'with a Quill editor in a nested resource' do
    it 'updates some HTML content of a new nested resource' do
      visit "/admin/authors/#{author.id}/edit"

      expect(page).to have_css('.posts.has_many_container .ql-editor', text: 'Some content...')
      find('.posts.has_many_container .has_many_add').click
      expect(page).to have_css('.posts.has_many_container .ql-editor', count: 2)

      fill_in('author[posts_attributes][1][title]', with: 'A new post')
      find('#author_posts_attributes_1_description_input .ql-editor').base.send_keys('new post text')
      find('[type="submit"]').click

      expect(page).to have_content('was successfully updated')
      expect(author.posts.last.description).to eq '<p>new post text</p>'
    end
  end
end
