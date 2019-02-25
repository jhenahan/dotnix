function get_pass(account)
  --pass = io.popen('pass ' .. account)
  --res = pass:read("*a")
  local status
  local res
  status, res = pipe_from('pass ' .. account)
  res = string.gsub(res, "\n", "")
  return res
end

dofile '/etc/configrules.lua'

function main()
  options.limit = 50
  options.timeout = 120
  options.keepalive = 5
  personal = IMAP {
    server = 'imap.mail.me.com',
    username = 'jhenahan',
    password = get_pass('jhenahan@me.com'),
    ssl = 'tls1',
  }

  work = IMAP {
    server = 'outlook.office365.com',
    username = 'jack.henahan@coxautoinc.com',
    password = get_pass('jack.henahan@coxautoinc.com'),
    ssl = 'tls1',
  }

  personal_mail = get_mail(personal)
  work_mail = get_mail(work)
  --destroy_mailboxes(personal)
  move_mail()
  cut_the_bullshit()
end

function get_mail(account)
  local mail = account.INBOX
  mail:check_status()
  local mails = mail:select_all()
  return mails
end

main()
