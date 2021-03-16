<?php


namespace App\Models;


use Illuminate\Database\Eloquent\Model;

class Project extends Model
{

    protected $table = 'Projects';
    public $timestamps = false;

    protected $fillable = [
        'id',
        'title',
        'todoSteps',
        'requiredProofs',
        'categoryId',
        'subCategoryId',
        'regionName',
        'countryNames',
        'workerNeeded',
        'requiredScreenShots',
        'estimatedDay',
        'estimatedCost',
        'eachWorkerEarn',
        'publishedBy',
        'isFinished',
        'fileUrl',
        'imageUrl',
        'adCost',
        'adDuration',
        'adPublishDate',
        'status',
        'ip',
        'modifiedBy',
        'createdAt'
    ];

    protected $casts = [
        'todoSteps' => 'array',
        'requiredProofs' => 'array',
        'countryNames' => 'array'
    ];
}
