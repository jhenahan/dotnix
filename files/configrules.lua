function move_mail()
  move_personal_mail()
  move_work_mail()
end

function cut_the_bullshit()
  delete_personal_mail()
  delete_work_mail()
end

function move_work_mail()
  mails = get_mail(work)
  archive_by_year(work, mails, "2012")
  archive_by_year(work, mails, "2013")
  archive_by_year(work, mails, "2014")
  archive_by_year(work, mails, "2015")
  archive_by_year(work, mails, "2016")
end

function move_personal_mail()
  local mails = personal_mail
  move_if_from_contains(personal, mails, "amazon.com", "Accounts/Amazon")
  move_if_from_contains(personal, mails, "support@betterment.com", "Accounts/Betterment")
  move_if_from_contains(personal, mails, "no-reply@coinbase.com", "Accounts/Coinbase")
  move_if_from_contains(personal, mails, "notifications@github.com", "Accounts/Github")
  move_if_from_contains(personal, mails, "community@gitlab.com", "Accounts/Gitlab")
  move_if_from_contains(personal, mails, "notify@keybase.io", "Accounts/Keybase")
  move_if_from_contains(personal, mails, "service@discoverstudentloans.com", "Accounts/Loans")
  move_if_from_contains(personal, mails, "CustomerService@navient.com", "Accounts/Loans")
  move_if_from_contains(personal, mails, "Student.Loans@citi.com", "Accounts/Loans")
  move_if_from_contains(personal, mails, "member@paypal.com", "Accounts/Paypal")
  move_if_from_contains(personal, mails, "service@paypal.com", "Accounts/Paypal")
  move_if_from_contains(personal, mails, "haskell-cafe", "Haskell/Haskell Cafe")
  move_if_from_contains(personal, mails, "udemy", "Accounts/Udemy")
  move_if_subject_contains(personal, mails, "[haskell-cafe]", "Haskell/Haskell Cafe")
  move_if_subject_contains(personal, mails, "[Haskell-Cafe]", "Haskell/Haskell Cafe")
  move_if_to_contains(personal, mails, "haskell-cafe", "Haskell/Haskell Cafe")
  move_if_to_contains(personal, mails, "agora-business", "Agora/Business")
  move_if_to_contains(personal, mails, "agora-discussion", "Agora/Discussion")
  move_if_to_contains(personal, mails, "agora-official", "Agora/Official")
  move_if_subject_contains(personal, mails, "[haskell-pipes]", "Haskell/Haskell Pipes")
  move_if_from_contains(personal, mails, "receipts@uber.com", "Receipts/Uber")
  move_if_from_contains(personal, mails, "puppetlabs.com", "Puppet Labs")
  move_if_from_contains(personal, mails, "bucklandconsultingservices.com", "Work/Buckland")
  move_if_from_contains(personal, mails, "thegrid.io", "Accounts/The Grid")
  move_if_from_contains(personal, mails, "thegrid.io", "Accounts/The Grid")
  move_if_from_contains(personal, mails, "periscopedata.com", "Periscope Blog")
  archive_by_year(personal, mails, "2012")
  archive_by_year(personal, mails, "2013")
  archive_by_year(personal, mails, "2014")
  archive_by_year(personal, mails, "2015")
  archive_by_year(personal, mails, "2016")
  archive_by_year(personal, mails, "2017")
  archive_by_year(personal, mails, "2018")
end

function delete_personal_mail()
  local mails = personal_mail
  delete_mail_from(personal, mails, "winooski@frontporchforum.com")
  delete_mail_from(personal, mails, "noreply@glassdoor.com")
  delete_mail_from(personal, mails, "dominos.com")
  delete_mail_from(personal, mails, "plus.google.com")
  delete_mail_from(personal, mails, "paypal@e.paypal.com")
  delete_mail_from(personal, mails, "mail@info.adobesystems.com")
  --delete_mail_from(personal, mails, "no-reply@e.udemymail.com")
  delete_mail_from(personal, mails, "unroll.me")
  delete_mail_from(personal, mails, "coursera")
  delete_mail_from(personal, mails, "VocelliPizza.fbmta.com")
  delete_mail_from(personal, mails, "explore.pinterest.com")
  if os.date("%A") == 'Friday' then
    delete_mail_from(personal, mails, 'info@bookbub.com')
  end
end

function delete_work_mail()
  local mails = work_mail
end

function move_if_subject_contains(account, mails, subject, mailbox)
  filtered = mails:contain_subject(subject)
  filtered:move_messages(account[mailbox]);
end

function move_if_to_contains(account, mails, to, mailbox)
  filtered = mails:contain_to(to)
  filtered:move_messages(account[mailbox]);
end

function move_if_from_contains(account, mails, from, mailbox)
  filtered = mails:contain_from(from)
  filtered:move_messages(account[mailbox]);
end

function archive_by_year(account, mails, year)
  date_first = "31-Dec-" .. year
  mailbox = "Archive/" .. year
  filtered = mails:arrived_before(date_first)
  filtered:move_messages(account[mailbox]);
end

function delete_mail_from(account, mails, from)
  filtered = mails:contain_from(from)
  filtered:delete_messages()
end

function delete_mail_if_subject_contains(account, mails, subject)
  filtered = mails:contain_subject(subject)
  filtered:delete_messages()
end
