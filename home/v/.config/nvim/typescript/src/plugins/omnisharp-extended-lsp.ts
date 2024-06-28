export const omnisharpExtendedLsp = {
    1: "Hoffs/omnisharp-extended-lsp.nvim",
    dependencies: ['neovim/nvim-lspconfig', 'hrsh7th/nvim-cmp'],
    ft: "cs",
    config: () => {
        const capabilities = lua.require('cmp_nvim_lsp').default_capabilities()
        capabilities.textDocument.completion.completionItem.snippetSupport = false
        const on_attach = (client: any, bufnr: number) => {
            const bufopts = { remap: false, silent: true, buffer: bufnr }
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
            vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, bufopts)
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
            vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
            vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
            vim.keymap.set('n', '<c-k>', () => {
                // vim.diagnostic.open_float(undefined, { focusable = false })
                vim.diagnostic.open_float({ focusable: false })
            }, bufopts)
            // vim.keymap.set('i', '<c-k>', vim.lsp.buf.signature_help, bufopts);
        }

        lua.require('lspconfig').omnisharp.setup({
            cmd: [
                "dotnet",
                vim.fn.expand('$HOME/Utilities/omnisharp-osx-arm64-net6.0/OmniSharp.dll')
            ],
            handlers: {
                "textDocument/definition": lua.require('omnisharp_extended').handler,
            },
            enable_editorconfig_support: true,
            enable_ms_build_load_projects_on_demand: false,
            enable_roslyn_analyzers: false,
            organize_imports_on_format: false,
            enable_import_completion: false,
            sdk_include_prereleases: true,
            analyze_open_documents_only: false,
            capabilities: capabilities,
            on_attach: (client, bufnr) => {
                if (client.name == "omnisharp") {
                    client.server_capabilities.semanticTokensProvider = {
                        full: (vim as any).empty_dict(),
                        legend: {
                            tokenModifiers: [ "static_symbol" ],
                            tokenTypes: [
                                "comment",
                                "excluded_code",
                                "identifier",
                                "keyword",
                                "keyword_control",
                                "number",
                                "operator",
                                "operator_overloaded",
                                "preprocessor_keyword",
                                "string",
                                "whitespace",
                                "text",
                                "static_symbol",
                                "preprocessor_text",
                                "punctuation",
                                "string_verbatim",
                                "string_escape_character",
                                "class_name",
                                "delegate_name",
                                "enum_name",
                                "interface_name",
                                "module_name",
                                "struct_name",
                                "type_parameter_name",
                                "field_name",
                                "enum_member_name",
                                "constant_name",
                                "local_name",
                                "parameter_name",
                                "method_name",
                                "extension_method_name",
                                "property_name",
                                "event_name",
                                "namespace_name",
                                "label_name",
                                "xml_doc_comment_attribute_name",
                                "xml_doc_comment_attribute_quotes",
                                "xml_doc_comment_attribute_value",
                                "xml_doc_comment_cdata_section",
                                "xml_doc_comment_comment",
                                "xml_doc_comment_delimiter",
                                "xml_doc_comment_entity_reference",
                                "xml_doc_comment_name",
                                "xml_doc_comment_processing_instruction",
                                "xml_doc_comment_text",
                                "xml_literal_attribute_name",
                                "xml_literal_attribute_quotes",
                                "xml_literal_attribute_value",
                                "xml_literal_cdata_section",
                                "xml_literal_comment",
                                "xml_literal_delimiter",
                                "xml_literal_embedded_expression",
                                "xml_literal_entity_reference",
                                "xml_literal_name",
                                "xml_literal_processing_instruction",
                                "xml_literal_text",
                                "regex_comment",
                                "regex_character_class",
                                "regex_anchor",
                                "regex_quantifier",
                                "regex_grouping",
                                "regex_alternation",
                                "regex_text",
                                "regex_self_escaped_character",
                                "regex_other_escape",
                            ],
                        },
                        range: true,
                    }
                    on_attach(client, bufnr)
                }
            },
        })
    },
}
