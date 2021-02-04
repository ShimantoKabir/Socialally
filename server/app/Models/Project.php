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
        'countryName',
        'workerNeeded',
        'requiredScreenShot',
        'estimatedDay',
        'estimatedCost',
        'applicantIds',
        'postedBy',
        'isFinished',
        'fileUrl',
        'imageUrl',
        'ip',
        'modifiedBy',
        'createdAt',
    ];

    protected $casts = [
        'todoSteps' => 'array',
        'requiredProofs' => 'array'
    ];

}
