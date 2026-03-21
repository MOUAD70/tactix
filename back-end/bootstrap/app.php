<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;


return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__ . '/../routes/web.php',
        api: __DIR__ . '/../routes/api.php',
        commands: __DIR__ . '/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->alias([
            'role' => \App\Http\Middleware\RoleMiddleware::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        // Handle ModelNotFoundException
        $exceptions->render(function (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            $model = class_basename($e->getModel());
            return response()->json([
                'message' => "{$model} not found.",
            ], 404);
        });

        // Handle AuthenticationException
        $exceptions->render(function (\Illuminate\Auth\AuthenticationException $e) {
            return response()->json([
                'message' => 'Unauthenticated. Please log in.',
            ], 401);
        });

        // Handle AuthorizationException
        $exceptions->render(function (\Illuminate\Auth\Access\AuthorizationException $e) {
            return response()->json([
                'message' => 'You are not authorized to perform this action.',
            ], 403);
        });

        // Handle ValidationException
        $exceptions->render(function (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'message' => 'The given data was invalid.',
                'errors' => $e->errors(),
            ], 422);
        });

        // Handle HttpException (includes abort() calls)
        $exceptions->render(function (\Symfony\Component\HttpKernel\Exception\HttpException $e) {
            return response()->json([
                'message' => $e->getMessage() ?: 'An error occurred.',
            ], $e->getStatusCode());
        });

        // Handle NotFoundHttpException
        $exceptions->render(function (\Symfony\Component\HttpKernel\Exception\NotFoundHttpException $e) {
            return response()->json([
                'message' => 'The requested endpoint does not exist.',
            ], 404);
        });

        // Handle MethodNotAllowedHttpException
        $exceptions->render(function (\Symfony\Component\HttpKernel\Exception\MethodNotAllowedHttpException $e) {
            return response()->json([
                'message' => 'HTTP method not allowed.',
            ], 405);
        });

        // Catch-all for any other exception
        $exceptions->render(function (\Throwable $e) {
            return response()->json([
                'message' => 'Something went wrong. Please try again later.',
            ], 500);
        });
    })->create();
