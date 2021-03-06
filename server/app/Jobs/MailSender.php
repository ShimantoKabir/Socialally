<?php


namespace App\Jobs;

use Illuminate\Support\Facades\Mail;

class MailSender extends Job
{

    protected $data;

    public function __construct($data)
    {

        $this->data = $data;
    }

    public function handle()
    {

        $mailData = array(
            'email' => $this->data['email'],
            'verificationLink' => $this->data['verificationLink']
        );

        Mail::send("mail.emailVerification", $mailData, function ($message) use ($mailData) {
            $message->to($mailData['email'])->subject('Email Verification');
        });
    }
}
