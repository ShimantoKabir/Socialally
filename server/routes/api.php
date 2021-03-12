<?php

use App\Http\Controllers\TestCtl;
use App\Http\Controllers\ProjectCtl;
use App\Http\Controllers\WelcomeCtl;
use App\Http\Controllers\QuestionCtl;
use App\Http\Controllers\UserInfoCtl;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AppConstantCtl;
use App\Http\Controllers\TransactionCtl;
use App\Http\Controllers\NotificationCtl;
use App\Http\Controllers\AdvertisementCtl;
use App\Http\Controllers\PaymentGatewayCtl;
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
Route::get('/users/query', [UserInfoCtl::class, 'readByQuery']);
// -- ?first-name=jon
Route::post('/users/image', [UserInfoCtl::class, 'uploadImage']);
Route::put('/users/password', [UserInfoCtl::class, 'changePassword']);
Route::get('/users/{id}', [UserInfoCtl::class, 'readById']);
Route::get('/users/user-info-id/query', [UserInfoCtl::class, 'readByUserInfoId']);
Route::get('/users/paginate/query', [UserInfoCtl::class, 'read']);
// -- ?par-page=5&page-index=1
Route::put('/users/status', [UserInfoCtl::class, 'changeStatus']);

// project category
Route::get('/categories', [ProjectCategoryCtl::class, 'readCategory']);
Route::post('/categories', [ProjectCategoryCtl::class, 'createCategory']);
Route::put('/categories', [ProjectCategoryCtl::class, 'updateCategory']);
Route::delete('/categories/{categoryId}', [ProjectCategoryCtl::class, 'deleteCategory']);
Route::get('/categories/sub/{categoryId}', [ProjectCategoryCtl::class, 'getSubCategoriesById']);
Route::get('/sub-categories', [ProjectCategoryCtl::class, 'getSubCategories']);
Route::post('/sub-categories', [ProjectCategoryCtl::class, 'createSubCategory']);
Route::put('/sub-categories', [ProjectCategoryCtl::class, 'updateSubCategory']);
Route::delete('/sub-categories/{id}', [ProjectCategoryCtl::class, 'deleteSubCategory']);

// project
Route::post('/projects', [ProjectCtl::class, 'create']);
Route::get('/projects/query', [ProjectCtl::class, 'readByQuery']);
// -- ?accept-publisher=0&user-info-id=2&par-page=2&page-index=5&
Route::get('/projects', [ProjectCtl::class, 'read']);
Route::get('/projects/title-query', [ProjectCtl::class, 'readByTitle']);
// -- ?title=tile&user-info-id=2
Route::put('/projects/advertisements', [ProjectCtl::class, 'addAdToProject']);
Route::put('/projects', [ProjectCtl::class, 'update']);
Route::get('/projects/approve-query', [ProjectCtl::class, 'readByStatus']);
Route::put('/projects/status', [ProjectCtl::class, 'updateStatus']);
// -- ?status=pending

// proof submission
Route::post('/proof-submissions', [ProofSubmissionCtl::class, 'create']);
Route::put('/proof-submissions', [ProofSubmissionCtl::class, 'update']);

// transactions
Route::post('/transactions', [TransactionCtl::class, 'create']);
Route::get('/transactions/query', [TransactionCtl::class, 'readByQuery']);
Route::put('/transactions', [TransactionCtl::class, 'update']);
Route::get('/transactions/balance-summary-query', [TransactionCtl::class, 'getBalanceSummary']);
Route::get('/transactions/overview', [TransactionCtl::class, 'getTransactionOverview']);
Route::get('/transactions/manual', [TransactionCtl::class, 'createManualTransaction']);
// -- ?start-date=2020-01-01&end-date=2020-01-31

// notifications
Route::get('/notifications/query', [NotificationCtl::class, 'readByQuery']);
Route::put('/notifications', [NotificationCtl::class, 'update']);
Route::post('/notifications', [NotificationCtl::class, 'create']);

// advertisements
Route::get('/advertisements/query', [AdvertisementCtl::class, 'readByQuery']);
Route::post('/advertisements', [AdvertisementCtl::class, 'create']);

// app constant
Route::get('/app-constants/settings/general', [AppConstantCtl::class, 'getGeneralSettingData']);
Route::put('/app-constants/settings/general', [AppConstantCtl::class, 'updateGeneralSettingData']);
Route::get('/app-constants/settings/ad-cost-plans', [AppConstantCtl::class, 'getAddCostPlanList']);
Route::post('/app-constants/settings/ad-cost-plans', [AppConstantCtl::class, 'createAddCostPlan']);
Route::delete('/app-constants/settings/ad-cost-plans', [AppConstantCtl::class, 'deleteAddCostPlan']);
Route::get('/app-constants/settings/support-infos', [AppConstantCtl::class, 'getSupportInfoList']);
Route::post('/app-constants/settings/support-infos', [AppConstantCtl::class, 'createSupportInfo']);
Route::delete('/app-constants/settings/support-infos', [AppConstantCtl::class, 'deleteSupportInfo']);

// payment gateways
Route::get('/payment-gateways', [PaymentGatewayCtl::class, 'read']);
Route::post('/payment-gateways', [PaymentGatewayCtl::class, 'create']);
Route::put('/payment-gateways', [PaymentGatewayCtl::class, 'update']);
Route::delete('/payment-gateways/{id}', [PaymentGatewayCtl::class, 'delete']);

// welcome
Route::get('/welcome', [WelcomeCtl::class, 'read']);
// time=12:00:00

// questions
Route::get('/questions/query', [QuestionCtl::class, 'readByQuery']);
Route::post('/questions', [QuestionCtl::class, 'create']);
Route::put('/questions', [QuestionCtl::class, 'update']);
Route::delete('/questions/{id}', [QuestionCtl::class, 'delete']);
