# API Routes Reference

Base URL local: `/api`

## Auth

- `No`: endpoint publico.
- `Bearer`: requiere header `Authorization: Bearer <access_token>`.
- `Bearer (manual)`: requiere el mismo header pero valida el token manualmente en el controller.

## Return Types

- Los tipos listados abajo salen de [src/types/database.types.ts](src/types/database.types.ts), [src/types/professional.types.ts](src/types/professional.types.ts), [src/types/suscription-price.types.ts](src/types/suscription-price.types.ts) y los request de [src/request](src/request).
- Cuando una ruta devuelve una respuesta de Supabase Auth y el proyecto no la tipa con una interface propia, se deja indicado como `Supabase auth response`.
- Cuando el controller no declara un tipo y delega directo al service, se deja el tipo inferido desde el service o el repositorio. Si tampoco existe un contrato fuerte, se indica `any` o `void`.

## Registered Endpoints

### Health

| Method | Path          | Auth | Input | Returns                |
| ------ | ------------- | ---- | ----- | ---------------------- |
| GET    | `/api/health` | No   | None  | `HealthStatusResponse` |

### Professionals

| Method | Path                     | Auth   | Input                   | Returns                              |
| ------ | ------------------------ | ------ | ----------------------- | ------------------------------------ |
| GET    | `/api/professionals`     | No     | Query: `limit?: number` | `ProfessionalSummary[]`              |
| GET    | `/api/professionals/me`  | Bearer | None                    | `ProfessionalRow \| null`            |
| GET    | `/api/professionals/:id` | No     | Param: `id: number`     | `any` (professional + profile embed) |

#### Examples: Professionals

`GET /api/professionals/me`

Headers:

```http
Authorization: Bearer <access_token>
```

Response 200:

```json
{
  "id": 12,
  "user_id": "f6c1b790-6f6b-4c78-b93d-37d8a6dcb2a1",
  "bio": "Electricista matriculado",
  "rating_avg": 4.8,
  "is_active": true,
  "account_type": "individual",
  "created_at": "2026-04-20T10:15:00.000Z",
  "updated_at": "2026-04-22T18:40:00.000Z",
  "deleted_at": null,
  "web_url": null,
  "is_matriculate": true,
  "emergency": false
}
```

`GET /api/professionals/:id`

Example:

```http
GET /api/professionals/12
```

Response 200:

```json
{
  "id": 12,
  "user_id": "f6c1b790-6f6b-4c78-b93d-37d8a6dcb2a1",
  "bio": "Electricista matriculado",
  "rating_avg": 4.8,
  "is_active": true,
  "account_type": "individual",
  "created_at": "2026-04-20T10:15:00.000Z",
  "updated_at": "2026-04-22T18:40:00.000Z",
  "Profile": {
    "id": "f6c1b790-6f6b-4c78-b93d-37d8a6dcb2a1",
    "display_name": "Juan Perez"
  }
}
```

### Auth

| Method | Path                       | Auth            | Input                                          | Returns                  |
| ------ | -------------------------- | --------------- | ---------------------------------------------- | ------------------------ |
| POST   | `/api/auth/register`       | No              | Body: `{ email: string; password: string }`    | `Supabase auth response` |
| POST   | `/api/auth/login`          | No              | Body: `{ email: string; password: string }`    | `Supabase auth response` |
| POST   | `/api/auth/login/google`   | No              | Body: `{ access_token: string }`               | `Supabase auth response` |
| POST   | `/api/auth/login/facebook` | No              | Body: `{ access_token: string }`               | `Supabase auth response` |
| POST   | `/api/auth/reset-password` | No              | Body: `{ email: string }`                      | `Supabase auth response` |
| GET    | `/api/auth/session`        | Bearer (manual) | Header: `Authorization: Bearer <access_token>` | `Supabase auth response` |

### Users

| Method | Path                                      | Auth   | Input                                    | Returns                                                                           |
| ------ | ----------------------------------------- | ------ | ---------------------------------------- | --------------------------------------------------------------------------------- |
| GET    | `/api/users/roles`                        | No     | None                                     | `RoleRow[]`                                                                       |
| GET    | `/api/users/me/favorites`                 | Bearer | Query: `page?: string`, `limit?: string` | `{ data: any[]; count: number; page: number; limit: number; totalPages: number }` |
| POST   | `/api/users/me/favorites`                 | Bearer | Body: `{ professionalId: number }`       | `UserFavoriteRow`                                                                 |
| DELETE | `/api/users/me/favorites/:professionalId` | Bearer | Param: `professionalId: number`          | `void`                                                                            |

### Arca

| Method | Path                           | Auth | Input                      | Returns            |
| ------ | ------------------------------ | ---- | -------------------------- | ------------------ |
| GET    | `/api/arca/verify/:cuit`       | No   | Param: `cuit: string`      | `any`              |
| GET    | `/api/arca/company/:companyId` | No   | Param: `companyId: number` | `CompaniesArcaRow` |

### Addresses

| Method | Path                                          | Auth   | Input                                            | Returns        |
| ------ | --------------------------------------------- | ------ | ------------------------------------------------ | -------------- |
| GET    | `/api/addresses`                              | No     | None                                             | `any[]`        |
| GET    | `/api/addresses/my`                           | Bearer | None                                             | `AddressRow[]` |
| GET    | `/api/addresses/professional/:professionalId` | No     | Param: `professionalId: number`                  | `AddressRow[]` |
| POST   | `/api/addresses`                              | Bearer | Body: `Partial<AddressRow>`                      | `AddressRow`   |
| PUT    | `/api/addresses/:id`                          | Bearer | Param: `id: number`, Body: `Partial<AddressRow>` | `AddressRow`   |

### Communications

| Method | Path                                                        | Auth | Input                              | Returns               |
| ------ | ----------------------------------------------------------- | ---- | ---------------------------------- | --------------------- |
| GET    | `/api/communications/requests/user/:userId`                 | No   | Param: `userId: string`            | `ContactRequestRow[]` |
| GET    | `/api/communications/requests/professional/:professionalId` | No   | Param: `professionalId: number`    | `ContactRequestRow[]` |
| GET    | `/api/communications/requests/:requestId/messages`          | No   | Param: `requestId: number`         | `MessageRow[]`        |
| POST   | `/api/communications/contact-request`                       | No   | Body: `Partial<ContactRequestRow>` | `ContactRequestRow`   |

### Reviews

| Method | Path                                        | Auth | Input                           | Returns       |
| ------ | ------------------------------------------- | ---- | ------------------------------- | ------------- |
| GET    | `/api/reviews/professional/:professionalId` | No   | Param: `professionalId: number` | `ReviewRow[]` |
| POST   | `/api/reviews`                              | No   | Body: `Partial<ReviewRow>`      | `ReviewRow`   |

### Professional Details

| Method | Path                                                    | Auth | Input                           | Returns                         |
| ------ | ------------------------------------------------------- | ---- | ------------------------------- | ------------------------------- |
| GET    | `/api/professional-details/:professionalId/categories`  | No   | Param: `professionalId: number` | `ProfessionalCategoryRow[]`     |
| GET    | `/api/professional-details/:professionalId/credentials` | No   | Param: `professionalId: number` | `ProfessionalCredentialRow[]`   |
| GET    | `/api/professional-details/:professionalId/schedules`   | No   | Param: `professionalId: number` | `ProfessionalAvailabilityRow[]` |

### Products

| Method | Path                                                            | Auth   | Input                                                             | Returns                                                                                  |
| ------ | --------------------------------------------------------------- | ------ | ----------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| GET    | `/api/products`                                                 | No     | Query: `page?: number`, `limit?: number`                          | `{ data: ProductRow[]; count: number; page: number; limit: number; totalPages: number }` |
| GET    | `/api/products/:id`                                             | No     | Param: `id: number`                                               | `ProductRow`                                                                             |
| GET    | `/api/products/name/:name`                                      | No     | Param: `name: string`                                             | `ProductRow[]`                                                                           |
| GET    | `/api/products/category/:categoryId`                            | No     | Param: `categoryId: number`                                       | `ProductRow[]`                                                                           |
| GET    | `/api/products/professional/:professionalId`                    | No     | Param: `professionalId: number`                                   | `ProfessionalProductRow[]`                                                               |
| GET    | `/api/products/professional/:professionalId/only-products`      | No     | Param: `professionalId: number`                                   | `ProductRow[]`                                                                           |
| POST   | `/api/products`                                                 | Bearer | Body: `CreateProductRequest`                                      | `ProductRow`                                                                             |
| PUT    | `/api/products/:id`                                             | Bearer | Param: `id: number`, Body: `UpdateProductRequest`                 | `ProductRow`                                                                             |
| PUT    | `/api/products/professional/:professionalId/product/:productId` | Bearer | Param: `professionalId: number`, `productId: number`, Body: `any` | `any`                                                                                    |
| PUT    | `/api/products/update-prices`                                   | Bearer | Body: `UpdatePriceToManyRequest`                                  | `any`                                                                                    |
| PUT    | `/api/products/mass-update-prices`                              | Bearer | Body: `MassUpdatePriceRequest`                                    | `any`                                                                                    |
| POST   | `/api/products/assign-professional`                             | Bearer | Body: `AssignProductToProfessionalRequest`                        | `ProfessionalProductRow`                                                                 |
| DELETE | `/api/products/:productId/professional/:professionalId`         | Bearer | Param: `productId: number`, `professionalId: number`              | `void`                                                                                   |

### MercadoPago Webhook

| Method | Path                        | Auth | Input       | Returns                                            |
| ------ | --------------------------- | ---- | ----------- | -------------------------------------------------- |
| POST   | `/api/webhooks/mercadopago` | No   | Body: `any` | `{ message: string }` or `'Notification received'` |

### Provinces

| Method | Path                 | Auth | Input               | Returns         |
| ------ | -------------------- | ---- | ------------------- | --------------- |
| GET    | `/api/provinces`     | No   | None                | `ProvinceRow[]` |
| GET    | `/api/provinces/:id` | No   | Param: `id: number` | `ProvinceRow`   |

### Province Departments

| Method | Path                                             | Auth | Input                       | Returns                   |
| ------ | ------------------------------------------------ | ---- | --------------------------- | ------------------------- |
| GET    | `/api/province-departments`                      | No   | None                        | `ProvinceDepartmentRow[]` |
| GET    | `/api/province-departments/:id`                  | No   | Param: `id: number`         | `ProvinceDepartmentRow`   |
| GET    | `/api/province-departments/province/:provinceId` | No   | Param: `provinceId: number` | `ProvinceDepartmentRow[]` |

### Services

| Method | Path                                         | Auth   | Input                                             | Returns        |
| ------ | -------------------------------------------- | ------ | ------------------------------------------------- | -------------- |
| GET    | `/api/services`                              | No     | Query: `ServiceFilters`                           | `ServiceRow[]` |
| GET    | `/api/services/:id`                          | No     | Param: `id: number`                               | `ServiceRow`   |
| GET    | `/api/services/professional/:professionalId` | Bearer | Param: `professionalId: number`                   | `ServiceRow[]` |
| POST   | `/api/services`                              | Bearer | Body: `CreateServiceRequest`                      | `ServiceRow`   |
| PUT    | `/api/services/:id`                          | Bearer | Param: `id: number`, Body: `UpdateServiceRequest` | `ServiceRow`   |
| DELETE | `/api/services/:id`                          | Bearer | Param: `id: number`                               | `void`         |

### Categories Products

| Method | Path                           | Auth | Input               | Returns                |
| ------ | ------------------------------ | ---- | ------------------- | ---------------------- |
| GET    | `/api/categories/products`     | No   | None                | `CategoryProductRow[]` |
| GET    | `/api/categories/products/:id` | No   | Param: `id: number` | `CategoryProductRow`   |

### Categories Services

| Method | Path                           | Auth | Input               | Returns                |
| ------ | ------------------------------ | ---- | ------------------- | ---------------------- |
| GET    | `/api/categories/services`     | No   | None                | `CategoryServiceRow[]` |
| GET    | `/api/categories/services/:id` | No   | Param: `id: number` | `CategoryServiceRow`   |

### Suscription Price

| Method | Path                     | Auth | Input | Returns                      |
| ------ | ------------------------ | ---- | ----- | ---------------------------- |
| GET    | `/api/suscription-price` | No   | None  | `SuscriptionPriceResponse[]` |

### Companies

| Method | Path                 | Auth   | Input                                             | Returns        |
| ------ | -------------------- | ------ | ------------------------------------------------- | -------------- |
| GET    | `/api/companies`     | No     | None                                              | `CompanyRow[]` |
| GET    | `/api/companies/:id` | No     | Param: `id: number`                               | `CompanyRow`   |
| POST   | `/api/companies`     | Bearer | Body: `CreateCompanyRequest`                      | `CompanyRow`   |
| PUT    | `/api/companies/:id` | Bearer | Param: `id: number`, Body: `UpdateCompanyRequest` | `CompanyRow`   |

### Professional Availability

| Method | Path                                                          | Auth   | Input                                                  | Returns                         |
| ------ | ------------------------------------------------------------- | ------ | ------------------------------------------------------ | ------------------------------- |
| GET    | `/api/professional/availability/professional/:professionalId` | No     | Param: `professionalId: number`                        | `ProfessionalAvailabilityRow[]` |
| POST   | `/api/professional/availability/bulk`                         | Bearer | Body: `BulkAvailabilityRequest`                        | `ProfessionalAvailabilityRow[]` |
| PUT    | `/api/professional/availability/:id`                          | Bearer | Param: `id: number`, Body: `UpdateAvailabilityRequest` | `ProfessionalAvailabilityRow`   |
| DELETE | `/api/professional/availability/:id`                          | Bearer | Param: `id: number`                                    | `void`                          |

### Professional Ranking

| Method | Path                        | Auth | Input                                          | Returns                    |
| ------ | --------------------------- | ---- | ---------------------------------------------- | -------------------------- |
| GET    | `/api/professional-ranking` | No   | Query: `categoryId?: string`, `limit?: string` | `ProfessionalRankingRow[]` |

### Professional Proposals

| Method | Path                                     | Auth   | Input                                    | Returns                            |
| ------ | ---------------------------------------- | ------ | ---------------------------------------- | ---------------------------------- |
| POST   | `/api/professional-proposals`            | Bearer | Body: `Partial<ProfessionalProposalRow>` | `ProfessionalProposalRow`          |
| GET    | `/api/professional-proposals/received`   | Bearer | None                                     | `ProfessionalProposalRow[]`        |
| GET    | `/api/professional-proposals/sent`       | Bearer | None                                     | `ProfessionalProposalRow[]`        |
| GET    | `/api/professional-proposals/:id`        | Bearer | Param: `id: string`                      | `ProfessionalProposalRow`          |
| POST   | `/api/professional-proposals/:id/accept` | Bearer | Param: `id: string`                      | `ProfessionalProposalRow` or `any` |

## Declared But Not Registered In AppModule

### Video

| Method | Path                     | Auth              | Input                                                                     | Returns                              | Status                                                |
| ------ | ------------------------ | ----------------- | ------------------------------------------------------------------------- | ------------------------------------ | ----------------------------------------------------- |
| POST   | `/api/videos/upload-url` | Bearer (intended) | Body: `{ fileName: string; fileType: string; type: 'REEL' \| 'PROFILE' }` | `{ uploadUrl: string; key: string }` | Not registered in `AppModule`, currently inaccessible |

## Request Interfaces

### Product Requests

- `CreateProductRequest`: `ean`, `name`, `description?`, `brand?`, `image_url?`, `categories_products_id?`
- `UpdateProductRequest`: `ean?`, `name?`, `description?`, `brand?`, `image_url?`, `categories_products_id?`
- `UpdatePriceToManyRequest`: `productIds`, `professionalId`, `price`
- `AssignProductToProfessionalRequest`: `professional_id`, `product_id`, `price`, `sale_type`, `is_active?`, `stock?`
- `MassUpdatePriceRequest`: `professionalId`, `type`, `value`, `operation`

### Service Requests

- `CreateServiceRequest`: `name`, `categories_services_id`, `price`, `professional_id`, `description?`, `duration_minutes?`, `is_active?`
- `UpdateServiceRequest`: `name?`, `categories_services_id?`, `price?`, `description?`, `duration_minutes?`, `is_active?`
- `ServiceFilters`: `name?`, `categoryId?`, `minPrice?`, `maxPrice?`, `provinceId?`, `departmentId?`, `isActive?`

### Company Requests

- `CreateCompanyRequest`: `name?`, `tax_code?`, `arca_file?`, `professional_id`, `address_id`, `business_type?`, `public_trade?`
- `UpdateCompanyRequest`: `name?`, `tax_code?`, `arca_file?`, `professional_id?`, `address_id?`, `business_type?`, `public_trade?`

### Availability Requests

- `CreateAvailabilityRequest`: `day_of_week`, `start_time`, `end_time`, `is_available?`
- `UpdateAvailabilityRequest`: `day_of_week?`, `start_time?`, `end_time?`, `is_available?`
- `BulkAvailabilityRequest`: `availability: CreateAvailabilityRequest[]`

## Main Response Interfaces

- `HealthStatusResponse`
- `ProfessionalSummary`
- `RoleRow`
- `UserFavoriteRow`
- `CompaniesArcaRow`
- `AddressRow`
- `ContactRequestRow`
- `MessageRow`
- `ReviewRow`
- `ProfessionalCategoryRow`
- `ProfessionalCredentialRow`
- `ProfessionalAvailabilityRow`
- `ProductRow`
- `ProfessionalProductRow`
- `ProvinceRow`
- `ProvinceDepartmentRow`
- `ServiceRow`
- `CategoryProductRow`
- `CategoryServiceRow`
- `CompanyRow`
- `ProfessionalRankingRow`
- `ProfessionalProposalRow`
- `SuscriptionPriceResponse`
