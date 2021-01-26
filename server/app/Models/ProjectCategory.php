<?php


namespace App\Models;


use Illuminate\Database\Eloquent\Model;

class ProjectCategory extends Model
{

    protected $table = 'ProjectCategories';
    public $timestamps = false;

    protected $fillable = [
        'id',
        'categoryId',
        'categoryName',
        'subCategoryName',
        'ip',
        'modifiedBy',
        'createdAt',
    ];

}
