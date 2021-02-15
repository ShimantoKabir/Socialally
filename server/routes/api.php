<?php

use App\Http\Controllers\NotificationCtl;
use App\Http\Controllers\TestCtl;
use App\Http\Controllers\ProjectCtl;
use App\Http\Controllers\UserInfoCtl;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\TransactionCtl;
use App\Http\Controllers\ProjectCategoryCtl;
use App\Http\Controllers\ProofSubmissionCtl;

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
Route::get('/projects/query', [ProjectCtl::class, 'readByQuery']);
// -- ?accept-publisher=0&user-info-id=2&par-page=2&page-index=5&
Route::get('/projects', [ProjectCtl::class, 'read']);
Route::get('/projects/title-query', [ProjectCtl::class, 'readByTitle']);
// -- ?title=tile&user-info-id=2
Route::put('/projects/advertisements', [ProjectCtl::class, 'addAdToProject']);

// proof submission
Route::post('/proof-submissions', [ProofSubmissionCtl::class, 'create']);
Route::put('/proof-submissions', [ProofSubmissionCtl::class, 'update']);

// transactions
Route::post('/transactions', [TransactionCtl::class, 'create']);
Route::get('/transactions/query', [TransactionCtl::class, 'readByQuery']);
Route::put('/transactions', [TransactionCtl::class, 'update']);
Route::get('/transactions/balance-summary-query', [TransactionCtl::class, 'getBalanceSummary']);


// notifications
Route::get('/notifications/query', [NotificationCtl::class, 'readByQuery']);
Route::put('/notifications', [NotificationCtl::class, 'update']);
