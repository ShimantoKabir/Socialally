<?php

namespace App\Utilities;

use PHPMailer\PHPMailer\PHPMailer;

class PHPMailSender
{
    public static function send($mailData)
    {
        $mail = new PHPMailer;
        $mail->isSMTP();
        $mail->Host = env('MAIL_HOST');
        $mail->Port = env('MAIL_PORT');
        $mail->SMTPAuth = true;
        $mail->Username = env('MAIL_USERNAME');
        $mail->Password = env('MAIL_PASSWORD');
        $mail->setFrom(env('MAIL_USERNAME'), 'Socialally');
        $mail->addReplyTo(env('MAIL_USERNAME'), 'Socialally');
        $mail->addAddress($mailData['email']);
        $mail->Subject = 'Socialally email verification';
        $mail->Body = $mailData['body'];
        $mail->send();
    }
}
