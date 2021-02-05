<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;


class ProofSubmission extends Model
{

    protected $table = 'ProofSubmissions';
    public $timestamps = false;

    protected $fillable = [
        'id',
        'projectId',
        'submittedBy',
        'givenProofs',
        'givenScreenshotUrls',
        'status',
        'ip',
        'modifiedBy',
        'createdAt',
    ];

    protected $casts = [
        'givenProofs' => 'array',
        'givenScreenshotUrls' => 'array'
    ];
}
