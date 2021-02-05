<?php

use App\Http\Controllers\ProjectCategoryCtl;
use App\Http\Controllers\ProjectCtl;
use App\Http\Controllers\ProofSubmissionCtl;
use App\Http\Controllers\TestCtl;
use App\Http\Controllers\UserInfoCtl;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

// test
Route::get('/test', [TestCtl::class, 'test']);

// user info
Route::post('/users/registration', [UserInfoCtl::class, 'register']);
Route::post('/users/verification/email', [UserInfoCtl::class, 'verifyEmail']);
Route::post('/users/login', [UserInfoCtl::class, 'login']);
Route::put('/users', [UserInfoCtl::class, 'update']);
Route::post('/users/image', [UserInfoCtl::class, 'uploadImage']);

// project category
Route::get('/categories', [ProjectCategoryCtl::class, 'read']);
Route::get('/categories/sub/{categoryId}', [ProjectCategoryCtl::class, 'getSubCategoriesById']);

// project
Route::post('/projects', [ProjectCtl::class, 'create']);
Route::get('/projects', [ProjectCtl::class, 'read']);

// proof submission
Route::post('/proof-submissions', [ProofSubmissionCtl::class, 'create']);
Route::put('/proof-submissions', [ProofSubmissionCtl::class, 'update']);
Route::get('/proof-submissions/{projectId}', [ProofSubmissionCtl::class, 'readByProjectId']);
