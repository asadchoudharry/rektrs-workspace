<?php

use Illuminate\Support\Facades\Route;

// Plugin ki apni routes — admin surface hamesha 'web' + 'auth' +
// admin permission ke peeche. Slug-prefixed prefix rakho taake
// core routes se takrao na ho.
// Route::middleware(['web', 'auth', 'verified', 'approved', 'can:admin.plugins.update'])
//     ->prefix('admin/example')
//     ->name('admin.example.')
//     ->group(function () {
//         Route::get('/', ExampleController::class)->name('show');
//     });
