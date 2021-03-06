require 'spec_helper'

Capybara.javascript_driver = :webkit

feature '답변을 관리한다.', js: true do
  let(:questioner) { create(:user) }
  let(:answerer) { create(:user) }
  let(:question) { create(:question, user: questioner) }

  background do
    create(:answer,
      question: question,
      content: 'It is simple',
      user: answerer
    )

    create(:answer,
      question: question,
      content: 'really?',
      user: questioner
    )

    login_as(answerer)

    visit '/'
    click_link 'Bulletins'
    click_link 'Q&A'
    click_link 'Question Title'
  end

  scenario '답변 목록을 본다.' do
    expect(page).to have_content('It is simple')
  end

  scenario '답변 등록한다.' do
    fill_in '답변', with: '첫번째 답변'

    click_button '답변등록'

    expect(page).to have_content('첫번째 답변')
  end

  scenario '내용을 입력하지 않아 등록에 실패한다.' do
    fill_in '답변', with: ' '

    click_button '답변등록'

    expect(page).to have_content('답변에 내용을 입력해 주세요')
  end

  scenario '답변을 삭제한다.' do
    within('.answer-2') do
      expect(page).to_not have_content('삭제')      
    end

    page.driver.accept_js_confirms!

    within('.answer-1') do
      click_link '삭제'
    end

    expect(page).to_not have_content('It is simple')
  end

  scenario '답변을 삭제하지 않는다.' do
    page.driver.dismiss_js_confirms!

    within('.answer-1') do
      click_link '삭제'
    end

    expect(page).to have_content('It is simple')
  end

  scenario '답변을 추천한다.' do
    within('.answer-1') do
      expect(page).to have_content('0')
      click_button '추천'
      expect(page).to have_content('1')
    end
  end

  scenario '추천한 답변을 취소한다.' do
    within('.answer-1') do
      expect(page).to have_content('0')
      click_button '추천'
      expect(page).to have_content('1')
    end

    within('.answer-1') do
      expect(page).to have_content('1')
      click_button '추천취소'
      expect(page).to have_content('0')
    end
  end
end
