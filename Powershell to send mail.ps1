 #Sender and Recipient Info
$MailFrom = "rajasekharreddyb.dba@gmail.com"
$MailTo = "rajasekharreddyb.dba@gmail.com"

# Server Info
$SmtpServer = "smtp.gmail.com"
$SmtpPort = "2525"

# Message stuff
$MessageSubject = "Live your best life now" 
$Message = New-Object System.Net.Mail.MailMessage $MailFrom,$MailTo
$Message.IsBodyHTML = $true
$Message.Subject = $MessageSubject
$Message.Body = @'
<!DOCTYPE html>
<html>
<head>
</head>
<body>
This is a test message to trigger an ETR.
</body>
</html>
'@

# Construct the SMTP client object, credentials, and send
$Smtp = New-Object Net.Mail.SmtpClient($SmtpServer)
$Smtp.EnableSsl = $true
$Smtp.Send($Message)