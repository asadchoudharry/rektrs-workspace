# Phase C — C1 static render evidence (bench-free)

Generated from the shipped fixtures in `operqon_core/operqon_core/workspace/` (byte-identical to the catalogue render — pinned by `operqon_core/saas/tests/test_workspaces.py`). This pack proves the fixture DEFINITIONS and what each surface is composed of; the rendered pixels (styled cards, dock tile on each shell, per-role visibility) are **IMAGE-PROOF-OWED** for the next scratch-site proof on an oc10-final image, in the same battery style as `files/branding-proof/`.

Shared posture for every workspace: `public: 0`, role rows exactly as listed, content = header + card blocks + shortcuts only — no onboarding blocks, no report/number-card blocks (F5), no engine names anywhere.

## Operqon Home — `/app/operqon_home_ws`

- Roles: Operqon Tenant Admin, Operqon Branch Manager, Operqon Accounts User, Operqon Sales User, Operqon Stock User, Operqon Read Only, Operqon Support (Read Only)
- Icon: `milestone` (stock workspace vocabulary)
- What the tenant sees: The default landing for every scoped role (role_home_page already routes here and to the Operqon Home page). Header + the workspace set's own shortcuts: New Sales Invoice, Customers, Items, Point of Sale, Team & access. The dock shell around this workspace now heads with the Operqon tile (F4, app-level).

```json
{
 "doctype": "Workspace",
 "module": "OPERQON Core",
 "public": 0,
 "is_standard": 1,
 "for_user": "",
 "parent_page": "",
 "sequence_id": 1.0,
 "extends": "",
 "hide_custom": 0,
 "is_hidden": 0,
 "app": "operqon_core",
 "type": "Workspace",
 "indicator_color": "",
 "docstatus": 0,
 "name": "Operqon Home",
 "title": "Operqon Home",
 "icon": "milestone",
 "content": "[{\"id\": \"operqon_home_ws-01\", \"type\": \"shortcut\", \"data\": {\"shortcut_name\": \"Business workspace\", \"col\": 3}}, {\"id\": \"operqon_home_ws-03\", \"type\": \"shortcut\", \"data\": {\"shortcut_name\": \"Your company\", \"col\": 3}}, {\"id\": \"operqon_home_ws-05\", \"type\": \"shortcut\", \"data\": {\"shortcut_name\": \"Team & access\", \"col\": 3}}]",
 "cards": [],
 "links": [],
 "shortcuts": [
  {
   "name": "operqon_home_ws-02",
   "parent": "Operqon Home",
   "parenttype": "Workspace",
   "parentfield": "shortcuts",
   "docstatus": 0,
   "label": "Business workspace",
   "color": "",
   "doc_view": "",
   "stats_filter": "",
   "format": "",
   "url": "",
   "kanban_board": "",
   "type": "Page",
   "link_to": "operqon-home"
  },
  {
   "name": "operqon_home_ws-04",
   "parent": "Operqon Home",
   "parenttype": "Workspace",
   "parentfield": "shortcuts",
   "docstatus": 0,
   "label": "Your company",
   "color": "",
   "doc_view": "",
   "stats_filter": "",
   "format": "",
   "url": "",
   "kanban_board": "",
   "type": "DocType",
   "link_to": "Company"
  },
  {
   "name": "operqon_home_ws-06",
   "parent": "Operqon Home",
   "parenttype": "Workspace",
   "parentfield": "shortcuts",
   "docstatus": 0,
   "label": "Team & access",
   "color": "",
   "doc_view": "",
   "stats_filter": "",
   "format": "",
   "url": "",
   "kanban_board": "",
   "type": "DocType",
   "link_to": "Operqon User Scope"
  }
 ],
 "roles": [
  {
   "name": "operqon_home_ws-07",
   "parent": "Operqon Home",
   "parenttype": "Workspace",
   "parentfield": "roles",
   "docstatus": 0,
   "role": "Operqon Tenant Admin"
  },
  {
   "name": "operqon_home_ws-08",
   "parent": "Operqon Home",
   "parenttype": "Workspace",
   "parentfield": "roles",
   "docstatus": 0,
   "role": "Operqon Branch Manager"
  },
  {
   "name": "operqon_home_ws-09",
   "parent": "Operqon Home",
   "parenttype": "Workspace",
   "parentfield": "roles",
   "docstatus": 0,
   "role": "Operqon Accounts User"
  },
  {
   "name": "operqon_home_ws-10",
   "parent": "Operqon Home",
   "parenttype": "Workspace",
   "parentfield": "roles",
   "docstatus": 0,
   "role": "Operqon Sales User"
  },
  {
   "name": "operqon_home_ws-11",
   "parent": "Operqon Home",
   "parenttype": "Workspace",
   "parentfield": "roles",
   "docstatus": 0,
   "role": "Operqon Stock User"
  },
  {
   "name": "operqon_home_ws-12",
   "parent": "Operqon Home",
   "parenttype": "Workspace",
   "parentfield": "roles",
   "docstatus": 0,
   "role": "Operqon Read Only"
  },
  {
   "name": "operqon_home_ws-13",
   "parent": "Operqon Home",
   "parenttype": "Workspace",
   "parentfield": "roles",
   "docstatus": 0,
   "role": "Operqon Support (Read Only)"
  }
 ]
}
```

## Operqon Sales — `/app/operqon_sales`

- Roles: Operqon Tenant Admin, Operqon Branch Manager, Operqon Sales User, Operqon Read Only, Operqon Support (Read Only)
- Icon: `sell` (stock workspace vocabulary)
- What the tenant sees: Sales work: Quotations/Sales Orders/Delivery Notes/Sales Invoices/Payment Entries cards, route shortcuts to the stock Point of Sale page (renamed by C4), Customers, and Items. No report or number-card blocks.

```json
{
 "doctype": "Workspace",
 "module": "OPERQON Core",
 "public": 0,
 "is_standard": 1,
 "for_user": "",
 "parent_page": "",
 "sequence_id": 2.0,
 "extends": "",
 "hide_custom": 0,
 "is_hidden": 0,
 "app": "operqon_core",
 "type": "Workspace",
 "indicator_color": "",
 "docstatus": 0,
 "name": "Operqon Sales",
 "title": "Operqon Sales",
 "icon": "sell",
 "content": "[{\"id\": \"operqon_sales-01\", \"type\": \"header\", \"data\": {\"text\": \"Sell\", \"col\": 12}}, {\"id\": \"operqon_sales-02\", \"type\": \"card\", \"data\": {\"card_name\": \"Selling\", \"col\": 6}}, {\"id\": \"operqon_sales-07\", \"type\": \"card\", \"data\": {\"card_name\": \"Billing\", \"col\": 6}}, {\"id\": \"operqon_sales-11\", \"type\": \"header\", \"data\": {\"text\": \"Quick Access\", \"col\": 12}}, {\"id\": \"operqon_sales-12\", \"type\": \"shortcut\", \"data\": {\"shortcut_name\": \"Sales Orders\", \"col\": 3}}, {\"id\": \"operqon_sales-14\", \"type\": \"shortcut\", \"data\": {\"shortcut_name\": \"Customers\", \"col\": 3}}]",
 "cards": [
  {
   "name": "operqon_sales-06",
   "parent": "Operqon Sales",
   "parenttype": "Workspace",
   "parentfield": "cards",
   "docstatus": 0,
   "label": "Selling",
   "card_links": [
    {
     "name": "operqon_sales-03",
     "parent": "Operqon Sales",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Quotation",
     "link_type_name": "",
     "label": "Quotations",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    },
    {
     "name": "operqon_sales-04",
     "parent": "Operqon Sales",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Sales Order",
     "link_type_name": "",
     "label": "Sales Orders",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    },
    {
     "name": "operqon_sales-05",
     "parent": "Operqon Sales",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Customer",
     "link_type_name": "",
     "label": "Customers",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    }
   ]
  },
  {
   "name": "operqon_sales-10",
   "parent": "Operqon Sales",
   "parenttype": "Workspace",
   "parentfield": "cards",
   "docstatus": 0,
   "label": "Billing",
   "card_links": [
    {
     "name": "operqon_sales-08",
     "parent": "Operqon Sales",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Sales Invoice",
     "link_type_name": "",
     "label": "Sales Invoices",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    },
    {
     "name": "operqon_sales-09",
     "parent": "Operqon Sales",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Delivery Note",
     "link_type_name": "",
     "label": "Delivery Notes",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    }
   ]
  }
 ],
 "links": [
  {
   "name": "operqon_sales-16",
   "parent": "Operqon Sales",
   "parenttype": "Workspace",
   "parentfield": "links",
   "docstatus": 0,
   "hidden": 0,
   "is_query_report": 0,
   "label": "Point of Sale",
   "dependencies": "",
   "only_for": "",
   "onboard": 0,
   "type": "Link",
   "link_type": "Page",
   "link_to": "point-of-sale",
   "link_type_name": ""
  }
 ],
 "shortcuts": [
  {
   "name": "operqon_sales-13",
   "parent": "Operqon Sales",
   "parenttype": "Workspace",
   "parentfield": "shortcuts",
   "docstatus": 0,
   "label": "Sales Orders",
   "color": "",
   "doc_view": "",
   "stats_filter": "",
   "format": "",
   "url": "",
   "kanban_board": "",
   "type": "DocType",
   "link_to": "Sales Order"
  },
  {
   "name": "operqon_sales-15",
   "parent": "Operqon Sales",
   "parenttype": "Workspace",
   "parentfield": "shortcuts",
   "docstatus": 0,
   "label": "Customers",
   "color": "",
   "doc_view": "",
   "stats_filter": "",
   "format": "",
   "url": "",
   "kanban_board": "",
   "type": "DocType",
   "link_to": "Customer"
  }
 ],
 "roles": [
  {
   "name": "operqon_sales-17",
   "parent": "Operqon Sales",
   "parenttype": "Workspace",
   "parentfield": "roles",
   "docstatus": 0,
   "role": "Operqon Tenant Admin"
  },
  {
   "name": "operqon_sales-18",
   "parent": "Operqon Sales",
   "parenttype": "Workspace",
   "parentfield": "roles",
   "docstatus": 0,
   "role": "Operqon Branch Manager"
  },
  {
   "name": "operqon_sales-19",
   "parent": "Operqon Sales",
   "parenttype": "Workspace",
   "parentfield": "roles",
   "docstatus": 0,
   "role": "Operqon Sales User"
  },
  {
   "name": "operqon_sales-20",
   "parent": "Operqon Sales",
   "parenttype": "Workspace",
   "parentfield": "roles",
   "docstatus": 0,
   "role": "Operqon Read Only"
  },
  {
   "name": "operqon_sales-21",
   "parent": "Operqon Sales",
   "parenttype": "Workspace",
   "parentfield": "roles",
   "docstatus": 0,
   "role": "Operqon Support (Read Only)"
  }
 ]
}
```

## Operqon Buying — `/app/operqon_buying`

- Roles: Operqon Tenant Admin, Operqon Branch Manager, Operqon Accounts User, Operqon Stock User, Operqon Read Only, Operqon Support (Read Only)
- Icon: `buying` (stock workspace vocabulary)
- What the tenant sees: Buying work: purchase cycle cards (Supplier Quotation -> Goods Received Note), Supplier and Items cards.

```json
{
 "doctype": "Workspace",
 "module": "OPERQON Core",
 "public": 0,
 "is_standard": 1,
 "for_user": "",
 "parent_page": "",
 "sequence_id": 3.0,
 "extends": "",
 "hide_custom": 0,
 "is_hidden": 0,
 "app": "operqon_core",
 "type": "Workspace",
 "indicator_color": "",
 "docstatus": 0,
 "name": "Operqon Buying",
 "title": "Operqon Buying",
 "icon": "buying",
 "content": "[{\"id\": \"operqon_buying-01\", \"type\": \"header\", \"data\": {\"text\": \"Buy\", \"col\": 12}}, {\"id\": \"operqon_buying-02\", \"type\": \"card\", \"data\": {\"card_name\": \"Purchasing\", \"col\": 6}}, {\"id\": \"operqon_buying-07\", \"type\": \"card\", \"data\": {\"card_name\": \"Payables\", \"col\": 6}}, {\"id\": \"operqon_buying-10\", \"type\": \"header\", \"data\": {\"text\": \"Quick Access\", \"col\": 12}}, {\"id\": \"operqon_buying-11\", \"type\": \"shortcut\", \"data\": {\"shortcut_name\": \"Purchase Orders\", \"col\": 3}}, {\"id\": \"operqon_buying-13\", \"type\": \"shortcut\", \"data\": {\"shortcut_name\": \"Suppliers\", \"col\": 3}}]",
 "cards": [
  {
   "name": "operqon_buying-06",
   "parent": "Operqon Buying",
   "parenttype": "Workspace",
   "parentfield": "cards",
   "docstatus": 0,
   "label": "Purchasing",
   "card_links": [
    {
     "name": "operqon_buying-03",
     "parent": "Operqon Buying",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Purchase Order",
     "link_type_name": "",
     "label": "Purchase Orders",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    },
    {
     "name": "operqon_buying-04",
     "parent": "Operqon Buying",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Purchase Receipt",
     "link_type_name": "",
     "label": "Purchase Receipts",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    },
    {
     "name": "operqon_buying-05",
     "parent": "Operqon Buying",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Supplier",
     "link_type_name": "",
     "label": "Suppliers",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    }
   ]
  },
  {
   "name": "operqon_buying-09",
   "parent": "Operqon Buying",
   "parenttype": "Workspace",
   "parentfield": "cards",
   "docstatus": 0,
   "label": "Payables",
   "card_links": [
    {
     "name": "operqon_buying-08",
     "parent": "Operqon Buying",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Purchase Invoice",
     "link_type_name": "",
     "label": "Purchase Invoices",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    }
   ]
  }
 ],
 "links": [],
 "shortcuts": [
  {
   "name": "operqon_buying-12",
   "parent": "Operqon Buying",
   "parenttype": "Workspace",
   "parentfield": "shortcuts",
   "docstatus": 0,
   "label": "Purchase Orders",
   "color": "",
   "doc_view": "",
   "stats_filter": "",
   "format": "",
   "url": "",
   "kanban_board": "",
   "type": "DocType",
   "link_to": "Purchase Order"
  },
  {
   "name": "operqon_buying-14",
   "parent": "Operqon Buying",
   "parenttype": "Workspace",
   "parentfield": "shortcuts",
   "docstatus": 0,
   "label": "Suppliers",
   "color": "",
   "doc_view": "",
   "stats_filter": "",
   "format": "",
   "url": "",
   "kanban_board": "",
   "type": "DocType",
   "link_to": "Supplier"
  }
 ],
 "roles": [
  {
   "name": "operqon_buying-15",
   "parent": "Operqon Buying",
   "parenttype": "Workspace",
   "parentfield": "roles",
   "docstatus": 0,
   "role": "Operqon Tenant Admin"
  },
  {
   "name": "operqon_buying-16",
   "parent": "Operqon Buying",
   "parenttype": "Workspace",
   "parentfield": "roles",
   "docstatus": 0,
   "role": "Operqon Branch Manager"
  },
  {
   "name": "operqon_buying-17",
   "parent": "Operqon Buying",
   "parenttype": "Workspace",
   "parentfield": "roles",
   "docstatus": 0,
   "role": "Operqon Accounts User"
  },
  {
   "name": "operqon_buying-18",
   "parent": "Operqon Buying",
   "parenttype": "Workspace",
   "parentfield": "roles",
   "docstatus": 0,
   "role": "Operqon Stock User"
  },
  {
   "name": "operqon_buying-19",
   "parent": "Operqon Buying",
   "parenttype": "Workspace",
   "parentfield": "roles",
   "docstatus": 0,
   "role": "Operqon Read Only"
  },
  {
   "name": "operqon_buying-20",
   "parent": "Operqon Buying",
   "parenttype": "Workspace",
   "parentfield": "roles",
   "docstatus": 0,
   "role": "Operqon Support (Read Only)"
  }
 ]
}
```

## Operqon Stock — `/app/operqon_stock`

- Roles: Operqon Tenant Admin, Operqon Branch Manager, Operqon Stock User, Operqon Read Only, Operqon Support (Read Only)
- Icon: `stock` (stock workspace vocabulary)
- What the tenant sees: Stock work: Items/Warehouses, stock movements, and the ledger shortcuts — plain list links only.

```json
{
 "doctype": "Workspace",
 "module": "OPERQON Core",
 "public": 0,
 "is_standard": 1,
 "for_user": "",
 "parent_page": "",
 "sequence_id": 4.0,
 "extends": "",
 "hide_custom": 0,
 "is_hidden": 0,
 "app": "operqon_core",
 "type": "Workspace",
 "indicator_color": "",
 "docstatus": 0,
 "name": "Operqon Stock",
 "title": "Operqon Stock",
 "icon": "stock",
 "content": "[{\"id\": \"operqon_stock-01\", \"type\": \"header\", \"data\": {\"text\": \"Stock\", \"col\": 12}}, {\"id\": \"operqon_stock-02\", \"type\": \"card\", \"data\": {\"card_name\": \"Inventory\", \"col\": 6}}, {\"id\": \"operqon_stock-07\", \"type\": \"card\", \"data\": {\"card_name\": \"Movements\", \"col\": 6}}, {\"id\": \"operqon_stock-11\", \"type\": \"header\", \"data\": {\"text\": \"Quick Access\", \"col\": 12}}, {\"id\": \"operqon_stock-12\", \"type\": \"shortcut\", \"data\": {\"shortcut_name\": \"Items\", \"col\": 3}}, {\"id\": \"operqon_stock-14\", \"type\": \"shortcut\", \"data\": {\"shortcut_name\": \"Stock Entries\", \"col\": 3}}]",
 "cards": [
  {
   "name": "operqon_stock-06",
   "parent": "Operqon Stock",
   "parenttype": "Workspace",
   "parentfield": "cards",
   "docstatus": 0,
   "label": "Inventory",
   "card_links": [
    {
     "name": "operqon_stock-03",
     "parent": "Operqon Stock",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Item",
     "link_type_name": "",
     "label": "Items",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    },
    {
     "name": "operqon_stock-04",
     "parent": "Operqon Stock",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Warehouse",
     "link_type_name": "",
     "label": "Warehouses",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    },
    {
     "name": "operqon_stock-05",
     "parent": "Operqon Stock",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Stock Entry",
     "link_type_name": "",
     "label": "Stock Entries",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    }
   ]
  },
  {
   "name": "operqon_stock-10",
   "parent": "Operqon Stock",
   "parenttype": "Workspace",
   "parentfield": "cards",
   "docstatus": 0,
   "label": "Movements",
   "card_links": [
    {
     "name": "operqon_stock-08",
     "parent": "Operqon Stock",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Delivery Note",
     "link_type_name": "",
     "label": "Delivery Notes",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    },
    {
     "name": "operqon_stock-09",
     "parent": "Operqon Stock",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Purchase Receipt",
     "link_type_name": "",
     "label": "Purchase Receipts",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    }
   ]
  }
 ],
 "links": [],
 "shortcuts": [
  {
   "name": "operqon_stock-13",
   "parent": "Operqon Stock",
   "parenttype": "Workspace",
   "parentfield": "shortcuts",
   "docstatus": 0,
   "label": "Items",
   "color": "",
   "doc_view": "",
   "stats_filter": "",
   "format": "",
   "url": "",
   "kanban_board": "",
   "type": "DocType",
   "link_to": "Item"
  },
  {
   "name": "operqon_stock-15",
   "parent": "Operqon Stock",
   "parenttype": "Workspace",
   "parentfield": "shortcuts",
   "docstatus": 0,
   "label": "Stock Entries",
   "color": "",
   "doc_view": "",
   "stats_filter": "",
   "format": "",
   "url": "",
   "kanban_board": "",
   "type": "DocType",
   "link_to": "Stock Entry"
  }
 ],
 "roles": [
  {
   "name": "operqon_stock-16",
   "parent": "Operqon Stock",
   "parenttype": "Workspace",
   "parentfield": "roles",
   "docstatus": 0,
   "role": "Operqon Tenant Admin"
  },
  {
   "name": "operqon_stock-17",
   "parent": "Operqon Stock",
   "parenttype": "Workspace",
   "parentfield": "roles",
   "docstatus": 0,
   "role": "Operqon Branch Manager"
  },
  {
   "name": "operqon_stock-18",
   "parent": "Operqon Stock",
   "parenttype": "Workspace",
   "parentfield": "roles",
   "docstatus": 0,
   "role": "Operqon Stock User"
  },
  {
   "name": "operqon_stock-19",
   "parent": "Operqon Stock",
   "parenttype": "Workspace",
   "parentfield": "roles",
   "docstatus": 0,
   "role": "Operqon Read Only"
  },
  {
   "name": "operqon_stock-20",
   "parent": "Operqon Stock",
   "parenttype": "Workspace",
   "parentfield": "roles",
   "docstatus": 0,
   "role": "Operqon Support (Read Only)"
  }
 ]
}
```

## Operqon Accounts — `/app/operqon_accounts`

- Roles: Operqon Tenant Admin, Operqon Branch Manager, Operqon Accounts User, Operqon Read Only, Operqon Support (Read Only)
- Icon: `accounting` (stock workspace vocabulary)
- What the tenant sees: Accounts work: journals, ledgers, invoices, payments, and a General Ledger report SHORTCUT (a navigation link — it renders no report content and resolves no number card inside the workspace, the F5-safe posture).

```json
{
 "doctype": "Workspace",
 "module": "OPERQON Core",
 "public": 0,
 "is_standard": 1,
 "for_user": "",
 "parent_page": "",
 "sequence_id": 5.0,
 "extends": "",
 "hide_custom": 0,
 "is_hidden": 0,
 "app": "operqon_core",
 "type": "Workspace",
 "indicator_color": "",
 "docstatus": 0,
 "name": "Operqon Accounts",
 "title": "Operqon Accounts",
 "icon": "accounting",
 "content": "[{\"id\": \"operqon_accounts-01\", \"type\": \"header\", \"data\": {\"text\": \"Money\", \"col\": 12}}, {\"id\": \"operqon_accounts-02\", \"type\": \"card\", \"data\": {\"card_name\": \"Receivables & Payables\", \"col\": 6}}, {\"id\": \"operqon_accounts-07\", \"type\": \"card\", \"data\": {\"card_name\": \"Books\", \"col\": 6}}, {\"id\": \"operqon_accounts-12\", \"type\": \"header\", \"data\": {\"text\": \"Quick Access\", \"col\": 12}}, {\"id\": \"operqon_accounts-13\", \"type\": \"shortcut\", \"data\": {\"shortcut_name\": \"Payments\", \"col\": 3}}, {\"id\": \"operqon_accounts-15\", \"type\": \"shortcut\", \"data\": {\"shortcut_name\": \"General Ledger\", \"col\": 3}}]",
 "cards": [
  {
   "name": "operqon_accounts-06",
   "parent": "Operqon Accounts",
   "parenttype": "Workspace",
   "parentfield": "cards",
   "docstatus": 0,
   "label": "Receivables & Payables",
   "card_links": [
    {
     "name": "operqon_accounts-03",
     "parent": "Operqon Accounts",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Sales Invoice",
     "link_type_name": "",
     "label": "Sales Invoices",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    },
    {
     "name": "operqon_accounts-04",
     "parent": "Operqon Accounts",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Purchase Invoice",
     "link_type_name": "",
     "label": "Purchase Invoices",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    },
    {
     "name": "operqon_accounts-05",
     "parent": "Operqon Accounts",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Payment Entry",
     "link_type_name": "",
     "label": "Payments",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    }
   ]
  },
  {
   "name": "operqon_accounts-11",
   "parent": "Operqon Accounts",
   "parenttype": "Workspace",
   "parentfield": "cards",
   "docstatus": 0,
   "label": "Books",
   "card_links": [
    {
     "name": "operqon_accounts-08",
     "parent": "Operqon Accounts",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Journal Entry",
     "link_type_name": "",
     "label": "Journal Entries",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    },
    {
     "name": "operqon_accounts-09",
     "parent": "Operqon Accounts",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Account",
     "link_type_name": "",
     "label": "Chart of Accounts",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    },
    {
     "name": "operqon_accounts-10",
     "parent": "Operqon Accounts",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Cost Center",
     "link_type_name": "",
     "label": "Cost Centers (Branches)",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    }
   ]
  }
 ],
 "links": [],
 "shortcuts": [
  {
   "name": "operqon_accounts-14",
   "parent": "Operqon Accounts",
   "parenttype": "Workspace",
   "parentfield": "shortcuts",
   "docstatus": 0,
   "label": "Payments",
   "color": "",
   "doc_view": "",
   "stats_filter": "",
   "format": "",
   "url": "",
   "kanban_board": "",
   "type": "DocType",
   "link_to": "Payment Entry"
  },
  {
   "name": "operqon_accounts-16",
   "parent": "Operqon Accounts",
   "parenttype": "Workspace",
   "parentfield": "shortcuts",
   "docstatus": 0,
   "label": "General Ledger",
   "color": "",
   "doc_view": "",
   "stats_filter": "",
   "format": "",
   "url": "",
   "kanban_board": "",
   "type": "Report",
   "link_to": "General Ledger"
  }
 ],
 "roles": [
  {
   "name": "operqon_accounts-17",
   "parent": "Operqon Accounts",
   "parenttype": "Workspace",
   "parentfield": "roles",
   "docstatus": 0,
   "role": "Operqon Tenant Admin"
  },
  {
   "name": "operqon_accounts-18",
   "parent": "Operqon Accounts",
   "parenttype": "Workspace",
   "parentfield": "roles",
   "docstatus": 0,
   "role": "Operqon Branch Manager"
  },
  {
   "name": "operqon_accounts-19",
   "parent": "Operqon Accounts",
   "parenttype": "Workspace",
   "parentfield": "roles",
   "docstatus": 0,
   "role": "Operqon Accounts User"
  },
  {
   "name": "operqon_accounts-20",
   "parent": "Operqon Accounts",
   "parenttype": "Workspace",
   "parentfield": "roles",
   "docstatus": 0,
   "role": "Operqon Read Only"
  },
  {
   "name": "operqon_accounts-21",
   "parent": "Operqon Accounts",
   "parenttype": "Workspace",
   "parentfield": "roles",
   "docstatus": 0,
   "role": "Operqon Support (Read Only)"
  }
 ]
}
```

## Operqon People — `/app/operqon_people`

- Roles: Operqon Tenant Admin, Operqon Branch Manager, Operqon Read Only, Operqon Support (Read Only)
- Icon: `hr` (stock workspace vocabulary)
- What the tenant sees: People work: the HR cycle (Employee -> Attendance -> Leave -> Payroll) and a Team & access card. Payroll/HR doctypes are governed per the Slice 3 matrix; HR/Payroll as a separate themed workspace is a C2-phase refinement (see report §13.2).

```json
{
 "doctype": "Workspace",
 "module": "OPERQON Core",
 "public": 0,
 "is_standard": 1,
 "for_user": "",
 "parent_page": "",
 "sequence_id": 6.0,
 "extends": "",
 "hide_custom": 0,
 "is_hidden": 0,
 "app": "operqon_core",
 "type": "Workspace",
 "indicator_color": "",
 "docstatus": 0,
 "name": "Operqon People",
 "title": "Operqon People",
 "icon": "hr",
 "content": "[{\"id\": \"operqon_people-01\", \"type\": \"header\", \"data\": {\"text\": \"People\", \"col\": 12}}, {\"id\": \"operqon_people-02\", \"type\": \"card\", \"data\": {\"card_name\": \"Team\", \"col\": 6}}, {\"id\": \"operqon_people-06\", \"type\": \"header\", \"data\": {\"text\": \"Quick Access\", \"col\": 12}}, {\"id\": \"operqon_people-07\", \"type\": \"shortcut\", \"data\": {\"shortcut_name\": \"Team & access\", \"col\": 3}}]",
 "cards": [
  {
   "name": "operqon_people-05",
   "parent": "Operqon People",
   "parenttype": "Workspace",
   "parentfield": "cards",
   "docstatus": 0,
   "label": "Team",
   "card_links": [
    {
     "name": "operqon_people-03",
     "parent": "Operqon People",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "User",
     "link_type_name": "",
     "label": "Team Members",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    },
    {
     "name": "operqon_people-04",
     "parent": "Operqon People",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Operqon User Scope",
     "link_type_name": "",
     "label": "Access & Branches",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    }
   ]
  }
 ],
 "links": [],
 "shortcuts": [
  {
   "name": "operqon_people-08",
   "parent": "Operqon People",
   "parenttype": "Workspace",
   "parentfield": "shortcuts",
   "docstatus": 0,
   "label": "Team & access",
   "color": "",
   "doc_view": "",
   "stats_filter": "",
   "format": "",
   "url": "",
   "kanban_board": "",
   "type": "DocType",
   "link_to": "Operqon User Scope"
  }
 ],
 "roles": [
  {
   "name": "operqon_people-09",
   "parent": "Operqon People",
   "parenttype": "Workspace",
   "parentfield": "roles",
   "docstatus": 0,
   "role": "Operqon Tenant Admin"
  },
  {
   "name": "operqon_people-10",
   "parent": "Operqon People",
   "parenttype": "Workspace",
   "parentfield": "roles",
   "docstatus": 0,
   "role": "Operqon Branch Manager"
  },
  {
   "name": "operqon_people-11",
   "parent": "Operqon People",
   "parenttype": "Workspace",
   "parentfield": "roles",
   "docstatus": 0,
   "role": "Operqon Read Only"
  },
  {
   "name": "operqon_people-12",
   "parent": "Operqon People",
   "parenttype": "Workspace",
   "parentfield": "roles",
   "docstatus": 0,
   "role": "Operqon Support (Read Only)"
  }
 ]
}
```

## Operqon Manufacturing — `/app/operqon_manufacturing`

- Roles: NONE in v1 (role-free — see note)
- Icon: `organization` (stock workspace vocabulary)
- What the tenant sees: Manufacturing area: full navigation (Items/BOMs/Work/Job Cards/Production) but ROLE-FREE in v1 — its doctypes are not yet in the governed role matrix, so no scoped role receives it until the matrix governs them (coverage lands with the C2 admin-surface phase).

```json
{
 "doctype": "Workspace",
 "module": "OPERQON Core",
 "public": 0,
 "is_standard": 1,
 "for_user": "",
 "parent_page": "",
 "sequence_id": 7.0,
 "extends": "",
 "hide_custom": 0,
 "is_hidden": 0,
 "app": "operqon_core",
 "type": "Workspace",
 "indicator_color": "",
 "docstatus": 0,
 "name": "Operqon Manufacturing",
 "title": "Operqon Manufacturing",
 "icon": "organization",
 "content": "[{\"id\": \"operqon_manufacturing-01\", \"type\": \"header\", \"data\": {\"text\": \"Production\", \"col\": 12}}, {\"id\": \"operqon_manufacturing-02\", \"type\": \"card\", \"data\": {\"card_name\": \"Planning\", \"col\": 6}}, {\"id\": \"operqon_manufacturing-07\", \"type\": \"header\", \"data\": {\"text\": \"Quick Access\", \"col\": 12}}, {\"id\": \"operqon_manufacturing-08\", \"type\": \"shortcut\", \"data\": {\"shortcut_name\": \"Work Orders\", \"col\": 3}}]",
 "cards": [
  {
   "name": "operqon_manufacturing-06",
   "parent": "Operqon Manufacturing",
   "parenttype": "Workspace",
   "parentfield": "cards",
   "docstatus": 0,
   "label": "Planning",
   "card_links": [
    {
     "name": "operqon_manufacturing-03",
     "parent": "Operqon Manufacturing",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Work Order",
     "link_type_name": "",
     "label": "Work Orders",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    },
    {
     "name": "operqon_manufacturing-04",
     "parent": "Operqon Manufacturing",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Job Card",
     "link_type_name": "",
     "label": "Job Cards",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    },
    {
     "name": "operqon_manufacturing-05",
     "parent": "Operqon Manufacturing",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "BOM",
     "link_type_name": "",
     "label": "Bill of Materials",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    }
   ]
  }
 ],
 "links": [],
 "shortcuts": [
  {
   "name": "operqon_manufacturing-09",
   "parent": "Operqon Manufacturing",
   "parenttype": "Workspace",
   "parentfield": "shortcuts",
   "docstatus": 0,
   "label": "Work Orders",
   "color": "",
   "doc_view": "",
   "stats_filter": "",
   "format": "",
   "url": "",
   "kanban_board": "",
   "type": "DocType",
   "link_to": "Work Order"
  }
 ],
 "roles": []
}
```

## Operqon Projects — `/app/operqon_projects`

- Roles: NONE in v1 (role-free — see note)
- Icon: `project` (stock workspace vocabulary)
- What the tenant sees: Projects area: Projects/Tasks/Timesheets navigation; ROLE-FREE in v1 (same ungoverned-doctypes ruling as Manufacturing).

```json
{
 "doctype": "Workspace",
 "module": "OPERQON Core",
 "public": 0,
 "is_standard": 1,
 "for_user": "",
 "parent_page": "",
 "sequence_id": 8.0,
 "extends": "",
 "hide_custom": 0,
 "is_hidden": 0,
 "app": "operqon_core",
 "type": "Workspace",
 "indicator_color": "",
 "docstatus": 0,
 "name": "Operqon Projects",
 "title": "Operqon Projects",
 "icon": "project",
 "content": "[{\"id\": \"operqon_projects-01\", \"type\": \"header\", \"data\": {\"text\": \"Projects\", \"col\": 12}}, {\"id\": \"operqon_projects-02\", \"type\": \"card\", \"data\": {\"card_name\": \"Delivery\", \"col\": 6}}, {\"id\": \"operqon_projects-07\", \"type\": \"header\", \"data\": {\"text\": \"Quick Access\", \"col\": 12}}, {\"id\": \"operqon_projects-08\", \"type\": \"shortcut\", \"data\": {\"shortcut_name\": \"Projects\", \"col\": 3}}]",
 "cards": [
  {
   "name": "operqon_projects-06",
   "parent": "Operqon Projects",
   "parenttype": "Workspace",
   "parentfield": "cards",
   "docstatus": 0,
   "label": "Delivery",
   "card_links": [
    {
     "name": "operqon_projects-03",
     "parent": "Operqon Projects",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Project",
     "link_type_name": "",
     "label": "Projects",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    },
    {
     "name": "operqon_projects-04",
     "parent": "Operqon Projects",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Task",
     "link_type_name": "",
     "label": "Tasks",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    },
    {
     "name": "operqon_projects-05",
     "parent": "Operqon Projects",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Timesheet",
     "link_type_name": "",
     "label": "Timesheets",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    }
   ]
  }
 ],
 "links": [],
 "shortcuts": [
  {
   "name": "operqon_projects-09",
   "parent": "Operqon Projects",
   "parenttype": "Workspace",
   "parentfield": "shortcuts",
   "docstatus": 0,
   "label": "Projects",
   "color": "",
   "doc_view": "",
   "stats_filter": "",
   "format": "",
   "url": "",
   "kanban_board": "",
   "type": "DocType",
   "link_to": "Project"
  }
 ],
 "roles": []
}
```

## Operqon Assets — `/app/operqon_assets`

- Roles: NONE in v1 (role-free — see note)
- Icon: `asset` (stock workspace vocabulary)
- What the tenant sees: Assets area: Assets/maintenance/depreciation navigation; ROLE-FREE in v1 (same ruling).

```json
{
 "doctype": "Workspace",
 "module": "OPERQON Core",
 "public": 0,
 "is_standard": 1,
 "for_user": "",
 "parent_page": "",
 "sequence_id": 9.0,
 "extends": "",
 "hide_custom": 0,
 "is_hidden": 0,
 "app": "operqon_core",
 "type": "Workspace",
 "indicator_color": "",
 "docstatus": 0,
 "name": "Operqon Assets",
 "title": "Operqon Assets",
 "icon": "asset",
 "content": "[{\"id\": \"operqon_assets-01\", \"type\": \"header\", \"data\": {\"text\": \"Assets\", \"col\": 12}}, {\"id\": \"operqon_assets-02\", \"type\": \"card\", \"data\": {\"card_name\": \"Register\", \"col\": 6}}, {\"id\": \"operqon_assets-06\", \"type\": \"header\", \"data\": {\"text\": \"Quick Access\", \"col\": 12}}, {\"id\": \"operqon_assets-07\", \"type\": \"shortcut\", \"data\": {\"shortcut_name\": \"Assets\", \"col\": 3}}]",
 "cards": [
  {
   "name": "operqon_assets-05",
   "parent": "Operqon Assets",
   "parenttype": "Workspace",
   "parentfield": "cards",
   "docstatus": 0,
   "label": "Register",
   "card_links": [
    {
     "name": "operqon_assets-03",
     "parent": "Operqon Assets",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Asset",
     "link_type_name": "",
     "label": "Assets",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    },
    {
     "name": "operqon_assets-04",
     "parent": "Operqon Assets",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Asset Category",
     "link_type_name": "",
     "label": "Asset Categories",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    }
   ]
  }
 ],
 "links": [],
 "shortcuts": [
  {
   "name": "operqon_assets-08",
   "parent": "Operqon Assets",
   "parenttype": "Workspace",
   "parentfield": "shortcuts",
   "docstatus": 0,
   "label": "Assets",
   "color": "",
   "doc_view": "",
   "stats_filter": "",
   "format": "",
   "url": "",
   "kanban_board": "",
   "type": "DocType",
   "link_to": "Asset"
  }
 ],
 "roles": []
}
```

## Operqon Quality — `/app/operqon_quality`

- Roles: NONE in v1 (role-free — see note)
- Icon: `quality` (stock workspace vocabulary)
- What the tenant sees: Quality area: goals/procedures/reviews/inspections navigation; ROLE-FREE in v1 (same ruling).

```json
{
 "doctype": "Workspace",
 "module": "OPERQON Core",
 "public": 0,
 "is_standard": 1,
 "for_user": "",
 "parent_page": "",
 "sequence_id": 10.0,
 "extends": "",
 "hide_custom": 0,
 "is_hidden": 0,
 "app": "operqon_core",
 "type": "Workspace",
 "indicator_color": "",
 "docstatus": 0,
 "name": "Operqon Quality",
 "title": "Operqon Quality",
 "icon": "quality",
 "content": "[{\"id\": \"operqon_quality-01\", \"type\": \"header\", \"data\": {\"text\": \"Quality\", \"col\": 12}}, {\"id\": \"operqon_quality-02\", \"type\": \"card\", \"data\": {\"card_name\": \"Checks\", \"col\": 6}}, {\"id\": \"operqon_quality-06\", \"type\": \"header\", \"data\": {\"text\": \"Quick Access\", \"col\": 12}}, {\"id\": \"operqon_quality-07\", \"type\": \"shortcut\", \"data\": {\"shortcut_name\": \"Quality Inspections\", \"col\": 3}}]",
 "cards": [
  {
   "name": "operqon_quality-05",
   "parent": "Operqon Quality",
   "parenttype": "Workspace",
   "parentfield": "cards",
   "docstatus": 0,
   "label": "Checks",
   "card_links": [
    {
     "name": "operqon_quality-03",
     "parent": "Operqon Quality",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Quality Inspection",
     "link_type_name": "",
     "label": "Quality Inspections",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    },
    {
     "name": "operqon_quality-04",
     "parent": "Operqon Quality",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Quality Goal",
     "link_type_name": "",
     "label": "Quality Goals",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    }
   ]
  }
 ],
 "links": [],
 "shortcuts": [
  {
   "name": "operqon_quality-08",
   "parent": "Operqon Quality",
   "parenttype": "Workspace",
   "parentfield": "shortcuts",
   "docstatus": 0,
   "label": "Quality Inspections",
   "color": "",
   "doc_view": "",
   "stats_filter": "",
   "format": "",
   "url": "",
   "kanban_board": "",
   "type": "DocType",
   "link_to": "Quality Inspection"
  }
 ],
 "roles": []
}
```

## Operqon Admin — `/app/operqon_admin`

- Roles: Operqon Tenant Admin
- Icon: `setting` (stock workspace vocabulary)
- What the tenant sees: Tenant-admin-only: Company, Team & access (Operqon User Scope), Users, and the Operqon point-of-sale device/sync/variance records. The stock ERPNext Home workspace is converged to System Manager only at the same install step (Administrator keeps framework access by role semantics).

```json
{
 "doctype": "Workspace",
 "module": "OPERQON Core",
 "public": 0,
 "is_standard": 1,
 "for_user": "",
 "parent_page": "",
 "sequence_id": 11.0,
 "extends": "",
 "hide_custom": 0,
 "is_hidden": 0,
 "app": "operqon_core",
 "type": "Workspace",
 "indicator_color": "",
 "docstatus": 0,
 "name": "Operqon Admin",
 "title": "Operqon Admin",
 "icon": "setting",
 "content": "[{\"id\": \"operqon_admin-01\", \"type\": \"header\", \"data\": {\"text\": \"Run your business\", \"col\": 12}}, {\"id\": \"operqon_admin-02\", \"type\": \"card\", \"data\": {\"card_name\": \"Company & Access\", \"col\": 6}}, {\"id\": \"operqon_admin-07\", \"type\": \"card\", \"data\": {\"card_name\": \"Point of Sale\", \"col\": 6}}, {\"id\": \"operqon_admin-12\", \"type\": \"header\", \"data\": {\"text\": \"Quick Access\", \"col\": 12}}, {\"id\": \"operqon_admin-13\", \"type\": \"shortcut\", \"data\": {\"shortcut_name\": \"Business workspace\", \"col\": 3}}, {\"id\": \"operqon_admin-15\", \"type\": \"shortcut\", \"data\": {\"shortcut_name\": \"Your Company\", \"col\": 3}}]",
 "cards": [
  {
   "name": "operqon_admin-06",
   "parent": "Operqon Admin",
   "parenttype": "Workspace",
   "parentfield": "cards",
   "docstatus": 0,
   "label": "Company & Access",
   "card_links": [
    {
     "name": "operqon_admin-03",
     "parent": "Operqon Admin",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Company",
     "link_type_name": "",
     "label": "Your Company",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    },
    {
     "name": "operqon_admin-04",
     "parent": "Operqon Admin",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Operqon User Scope",
     "link_type_name": "",
     "label": "Access & Branches",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    },
    {
     "name": "operqon_admin-05",
     "parent": "Operqon Admin",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "User",
     "link_type_name": "",
     "label": "Team Members",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    }
   ]
  },
  {
   "name": "operqon_admin-11",
   "parent": "Operqon Admin",
   "parenttype": "Workspace",
   "parentfield": "cards",
   "docstatus": 0,
   "label": "Point of Sale",
   "card_links": [
    {
     "name": "operqon_admin-08",
     "parent": "Operqon Admin",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Operqon POS Device",
     "link_type_name": "",
     "label": "POS Devices",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    },
    {
     "name": "operqon_admin-09",
     "parent": "Operqon Admin",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Operqon POS Sync Record",
     "link_type_name": "",
     "label": "POS Sync Records",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    },
    {
     "name": "operqon_admin-10",
     "parent": "Operqon Admin",
     "parenttype": "Workspace",
     "parentfield": "links",
     "docstatus": 0,
     "hidden": 0,
     "is_query_report": 0,
     "type": "Link",
     "link_type": "DocType",
     "link_to": "Operqon POS Variance Approval",
     "link_type_name": "",
     "label": "POS Variance Approvals",
     "dependencies": "",
     "only_for": "",
     "onboard": 0
    }
   ]
  }
 ],
 "links": [],
 "shortcuts": [
  {
   "name": "operqon_admin-14",
   "parent": "Operqon Admin",
   "parenttype": "Workspace",
   "parentfield": "shortcuts",
   "docstatus": 0,
   "label": "Business workspace",
   "color": "",
   "doc_view": "",
   "stats_filter": "",
   "format": "",
   "url": "",
   "kanban_board": "",
   "type": "Page",
   "link_to": "operqon-home"
  },
  {
   "name": "operqon_admin-16",
   "parent": "Operqon Admin",
   "parenttype": "Workspace",
   "parentfield": "shortcuts",
   "docstatus": 0,
   "label": "Your Company",
   "color": "",
   "doc_view": "",
   "stats_filter": "",
   "format": "",
   "url": "",
   "kanban_board": "",
   "type": "DocType",
   "link_to": "Company"
  }
 ],
 "roles": [
  {
   "name": "operqon_admin-17",
   "parent": "Operqon Admin",
   "parenttype": "Workspace",
   "parentfield": "roles",
   "docstatus": 0,
   "role": "Operqon Tenant Admin"
  }
 ]
}
```

## C3 — first-run panel (home page)

The panel renders on the Operqon Home PAGE (not a workspace) from the `operqon_core.firstrun.api.get_first_run_state` answer only; its states:

- **Fresh tenant, working role:** header 'Get started with Operqon', progress 'N of 5 done', one row per visible step (done = token-styled check + struck label; open = primary-styled action button: list/new per the step), and a 'Hide this checklist' dismiss button.
- **All steps done:** the panel never renders again (server stamps `completed_on` on the caller's Operqon First Run row).
- **Dismissed:** the panel never renders again for that user.
- **Read Only / Support / ineligible role:** no panel, no call result shown (server answers show=false).
- **API failure:** the panel removes itself silently — the home page never errors on the checklist's account.

Rendered pixels for all five states are **IMAGE-PROOF-OWED** (next scratch proof). The state model itself is fully bench-free-tested (`operqon_core/saas/tests/test_firstrun.py`).
