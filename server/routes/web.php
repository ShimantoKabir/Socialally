<?php

/** @var \Laravel\Lumen\Routing\Router $router */

/*
|--------------------------------------------------------------------------
| Application Routes
|--------------------------------------------------------------------------
|
| Here is where you can register all of the routes for an application.
| It is a breeze. Simply tell Lumen the URIs it should respond to
| and give it the Closure to call when that URI is requested.
|
*/

$router->get('/lumen/version', function () use ($router) {return $router->app->version();});
$router->get('/test', ['uses'=>'TestCtl@test']);

// user info
$router->post('/users/registration', ['uses' => 'UserInfoCtl@register']);
$router->post('/users/verification/email', ['uses'=>'UserInfoCtl@verifyEmail']);
$router->post('/users/login', ['uses'=>'UserInfoCtl@login']);
$router->put('/users', ['uses'=>'UserInfoCtl@update']);

// project category
$router->get('/categories', ['uses' => 'ProjectCategoryCtl@read']);
$router->get('/categories/sub/{categoryId}', ['uses' => 'ProjectCategoryCtl@getSubCategoriesById']);

// project
$router->post('/projects', ['uses' => 'ProjectCtl@create']);
$router->get('/projects', ['uses' => 'ProjectCtl@read']);





