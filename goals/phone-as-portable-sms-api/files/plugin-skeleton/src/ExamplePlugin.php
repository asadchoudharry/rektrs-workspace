<?php

namespace App\Plugins\Tools\Example;

use App\Contracts\Tools\ToolRuntimePlugin;
use App\Plugins\Tools\Example\Runtime\ExampleServiceProvider;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;

/**
 * Skeleton main class — one stub per contract family. Keep ONLY the
 * variant your plugin type needs and delete the others:
 *
 *  - tool:             implements ToolRuntimePlugin (this file)
 *  - ai_integration:   implements AiRuntimePlugin (same shape)
 *  - integration:      implements IntegrationRuntimePlugin (same shape)
 *  - channel:          implements ChannelRuntimePlugin + ChannelPlugin
 *  - payment_gateway:  implements PaymentGatewayPlugin
 *  - sms_provider:     implements SmsProviderPlugin
 *
 * Config yahan plugin row ke `config` JSON mein rehta hai
 * (PluginManager::configure). Jo plugin system_settings chahta hai
 * woh UsesSystemSettingConfig implement karke configuration() /
 * saveConfiguration() deta hai (Waba/Android precedent).
 */
final class ExamplePlugin implements ToolRuntimePlugin
{
    private array $config = [];

    public function __construct(array $config = [])
    {
        $this->config = $config;
    }

    public function provider(): string
    {
        return ExampleServiceProvider::class;
    }

    public function getName(): string
    {
        return 'Example Plugin';
    }

    public function getDescription(): string
    {
        return 'One line: what this plugin does.';
    }

    public function getIcon(): string
    {
        return '';
    }

    public function getVersion(): string
    {
        return '1.0.0';
    }

    public function getType(): string
    {
        return 'tool';
    }

    public function getAuthor(): string
    {
        return 'Sendqon';
    }

    public function getAuthorUrl(): string
    {
        return '';
    }

    /**
     * Activation gate: PluginManager activate() isConfigured() false
     * par refuse karta hai. Jo config activation se PEHLE lazmi ho
     * woh yahan check karo; jo config activation ke BAAD set hoti
     * hai (masalan koi enable switch) usay yahan mat rakho.
     */
    public function isConfigured(): bool
    {
        return true;
    }

    public function validateConfig(array $config): void
    {
        $this->config = Validator::make($config, [
            'enabled' => ['sometimes', 'boolean'],
        ])->validate();
    }

    public function validatedConfig(): array
    {
        return $this->config;
    }

    /**
     * Schema field keys: name, label, type, default, placeholder,
     * help, sensitive. Types (live UI se): text, password, number,
     * toggle, select, textarea, readonly, notice.
     */
    public function getConfigSchema(): array
    {
        return [
            ['name' => 'enabled', 'label' => __('Enable'), 'type' => 'toggle', 'default' => false],
        ];
    }
}
