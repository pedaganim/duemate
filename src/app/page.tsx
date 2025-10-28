import Link from "next/link";

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-b from-blue-50 to-white">
      {/* Header/Navigation */}
      <header className="bg-white shadow-sm">
        <nav className="mx-auto max-w-7xl px-4 py-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between">
            <div className="flex items-center">
              <h1 className="text-2xl font-bold text-blue-600">DueMate</h1>
            </div>
            <div className="hidden space-x-8 md:flex">
              <a href="#features" className="text-gray-700 transition hover:text-blue-600">
                Features
              </a>
              <a href="#about" className="text-gray-700 transition hover:text-blue-600">
                About
              </a>
              <a href="/api-docs" className="text-gray-700 transition hover:text-blue-600">
                API Docs
              </a>
            </div>
            <div>
              <a
                href="/api-docs"
                className="rounded-lg bg-blue-600 px-6 py-2 text-white transition hover:bg-blue-700"
              >
                Get Started
              </a>
            </div>
          </div>
        </nav>
      </header>

      {/* Hero Section */}
      <section className="mx-auto max-w-7xl px-4 py-20 sm:px-6 md:py-32 lg:px-8">
        <div className="text-center">
          <h2 className="mb-6 text-5xl font-bold text-gray-900 md:text-6xl">
            Invoice Management &amp; Payment Reminders for Small Businesses
          </h2>
          <p className="mx-auto mb-8 max-w-3xl text-xl text-gray-600 md:text-2xl">
            Automated invoice reminder system to help businesses get paid on time. Never miss a
            payment deadline again!
          </p>
          <div className="flex flex-col justify-center gap-4 sm:flex-row">
            <a
              href="/api-docs"
              className="rounded-lg bg-blue-600 px-8 py-4 text-lg font-semibold text-white shadow-lg transition hover:bg-blue-700"
            >
              Try the API
            </a>
            <a
              href="https://github.com/pedaganim/duemate"
              target="_blank"
              rel="noopener noreferrer"
              className="rounded-lg border-2 border-blue-600 bg-white px-8 py-4 text-lg font-semibold text-blue-600 shadow-lg transition hover:bg-blue-50"
            >
              View on GitHub
            </a>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="bg-white py-20">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <h3 className="mb-4 text-center text-4xl font-bold text-gray-900">Key Features</h3>
          <p className="mx-auto mb-12 max-w-2xl text-center text-xl text-gray-600">
            Everything you need to manage invoices and get paid faster
          </p>

          <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-3">
            {/* Feature 1 */}
            <div className="rounded-lg border border-gray-200 p-6 transition hover:shadow-lg">
              <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-lg bg-blue-100">
                <svg
                  className="h-6 w-6 text-blue-600"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                  />
                </svg>
              </div>
              <h4 className="mb-2 text-xl font-semibold text-gray-900">Invoice Management</h4>
              <p className="text-gray-600">
                Create, read, update, and delete invoices with ease. Full CRUD operations through a
                REST API.
              </p>
            </div>

            {/* Feature 2 */}
            <div className="rounded-lg border border-gray-200 p-6 transition hover:shadow-lg">
              <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-lg bg-blue-100">
                <svg
                  className="h-6 w-6 text-blue-600"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z"
                  />
                </svg>
              </div>
              <h4 className="mb-2 text-xl font-semibold text-gray-900">PDF Generation</h4>
              <p className="text-gray-600">
                Generate professional invoice PDFs with customizable templates. Preview and download
                instantly.
              </p>
            </div>

            {/* Feature 3 */}
            <div className="rounded-lg border border-gray-200 p-6 transition hover:shadow-lg">
              <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-lg bg-blue-100">
                <svg
                  className="h-6 w-6 text-blue-600"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
                  />
                </svg>
              </div>
              <h4 className="mb-2 text-xl font-semibold text-gray-900">Payment Reminders</h4>
              <p className="text-gray-600">
                Automated reminder system to ensure you get paid on time. Never chase payments
                again.
              </p>
            </div>

            {/* Feature 4 */}
            <div className="rounded-lg border border-gray-200 p-6 transition hover:shadow-lg">
              <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-lg bg-blue-100">
                <svg
                  className="h-6 w-6 text-blue-600"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z"
                  />
                </svg>
              </div>
              <h4 className="mb-2 text-xl font-semibold text-gray-900">Advanced Filtering</h4>
              <p className="text-gray-600">
                Filter invoices by status, client, date range, and more. Pagination support for
                large datasets.
              </p>
            </div>

            {/* Feature 5 */}
            <div className="rounded-lg border border-gray-200 p-6 transition hover:shadow-lg">
              <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-lg bg-blue-100">
                <svg
                  className="h-6 w-6 text-blue-600"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"
                  />
                </svg>
              </div>
              <h4 className="mb-2 text-xl font-semibold text-gray-900">Input Validation</h4>
              <p className="text-gray-600">
                Comprehensive validation for all invoice fields ensures data integrity and
                reliability.
              </p>
            </div>

            {/* Feature 6 */}
            <div className="rounded-lg border border-gray-200 p-6 transition hover:shadow-lg">
              <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-lg bg-blue-100">
                <svg
                  className="h-6 w-6 text-blue-600"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"
                  />
                </svg>
              </div>
              <h4 className="mb-2 text-xl font-semibold text-gray-900">API Documentation</h4>
              <p className="text-gray-600">
                Interactive Swagger/OpenAPI documentation makes integration quick and easy.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* About Section */}
      <section id="about" className="bg-blue-50 py-20">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="grid items-center gap-12 md:grid-cols-2">
            <div>
              <h3 className="mb-6 text-4xl font-bold text-gray-900">Built for Small Businesses</h3>
              <p className="mb-4 text-lg text-gray-600">
                DueMate is designed specifically for small businesses and freelancers who need a
                simple, reliable way to manage invoices and ensure timely payments.
              </p>
              <p className="mb-6 text-lg text-gray-600">
                With automated reminders and professional PDF generation, you can focus on your work
                while DueMate takes care of getting you paid.
              </p>
              <ul className="space-y-3">
                <li className="flex items-center text-gray-700">
                  <svg
                    className="mr-3 h-5 w-5 text-green-500"
                    fill="currentColor"
                    viewBox="0 0 20 20"
                  >
                    <path
                      fillRule="evenodd"
                      d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                      clipRule="evenodd"
                    />
                  </svg>
                  No authentication required for API
                </li>
                <li className="flex items-center text-gray-700">
                  <svg
                    className="mr-3 h-5 w-5 text-green-500"
                    fill="currentColor"
                    viewBox="0 0 20 20"
                  >
                    <path
                      fillRule="evenodd"
                      d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                      clipRule="evenodd"
                    />
                  </svg>
                  Auto-generated invoice numbers
                </li>
                <li className="flex items-center text-gray-700">
                  <svg
                    className="mr-3 h-5 w-5 text-green-500"
                    fill="currentColor"
                    viewBox="0 0 20 20"
                  >
                    <path
                      fillRule="evenodd"
                      d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                      clipRule="evenodd"
                    />
                  </svg>
                  RESTful API design
                </li>
                <li className="flex items-center text-gray-700">
                  <svg
                    className="mr-3 h-5 w-5 text-green-500"
                    fill="currentColor"
                    viewBox="0 0 20 20"
                  >
                    <path
                      fillRule="evenodd"
                      d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                      clipRule="evenodd"
                    />
                  </svg>
                  TypeScript for type safety
                </li>
              </ul>
            </div>
            <div className="rounded-lg bg-white p-8 shadow-lg">
              <h4 className="mb-4 text-2xl font-bold text-gray-900">Tech Stack</h4>
              <div className="space-y-4">
                <div>
                  <h5 className="mb-2 font-semibold text-gray-900">Frontend</h5>
                  <p className="text-gray-600">Next.js 14+ • React • TypeScript • Tailwind CSS</p>
                </div>
                <div>
                  <h5 className="mb-2 font-semibold text-gray-900">Backend</h5>
                  <p className="text-gray-600">Node.js • Express.js • TypeScript</p>
                </div>
                <div>
                  <h5 className="mb-2 font-semibold text-gray-900">Database</h5>
                  <p className="text-gray-600">SQLite • Prisma ORM</p>
                </div>
                <div>
                  <h5 className="mb-2 font-semibold text-gray-900">Tools</h5>
                  <p className="text-gray-600">PDFKit • Joi • Swagger/OpenAPI</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="bg-blue-600 py-20">
        <div className="mx-auto max-w-4xl px-4 text-center sm:px-6 lg:px-8">
          <h3 className="mb-6 text-4xl font-bold text-white">Ready to Get Started?</h3>
          <p className="mb-8 text-xl text-blue-100">
            Start managing your invoices and get paid on time with DueMate
          </p>
          <div className="flex flex-col justify-center gap-4 sm:flex-row">
            <a
              href="/api-docs"
              className="rounded-lg bg-white px-8 py-4 text-lg font-semibold text-blue-600 shadow-lg transition hover:bg-gray-100"
            >
              Explore API Documentation
            </a>
            <a
              href="https://github.com/pedaganim/duemate"
              target="_blank"
              rel="noopener noreferrer"
              className="rounded-lg bg-blue-700 px-8 py-4 text-lg font-semibold text-white shadow-lg transition hover:bg-blue-800"
            >
              Star on GitHub
            </a>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 py-12 text-gray-300">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="grid gap-8 md:grid-cols-3">
            <div>
              <h4 className="mb-4 text-xl font-bold text-white">DueMate</h4>
              <p className="text-gray-400">
                Invoice Management &amp; Payment Reminders for Small Businesses
              </p>
            </div>
            <div>
              <h5 className="mb-4 font-semibold text-white">Resources</h5>
              <ul className="space-y-2">
                <li>
                  <a href="/api-docs" className="transition hover:text-white">
                    API Documentation
                  </a>
                </li>
                <li>
                  <a
                    href="https://github.com/pedaganim/duemate"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="transition hover:text-white"
                  >
                    GitHub Repository
                  </a>
                </li>
              </ul>
            </div>
            <div>
              <h5 className="mb-4 font-semibold text-white">Legal</h5>
              <ul className="space-y-2">
                <li>
                  <a href="#" className="transition hover:text-white">
                    Privacy Policy
                  </a>
                </li>
                <li>
                  <a href="#" className="transition hover:text-white">
                    Terms of Service
                  </a>
                </li>
              </ul>
            </div>
          </div>
          <div className="mt-8 border-t border-gray-800 pt-8 text-center text-gray-400">
            <p>&copy; {new Date().getFullYear()} DueMate. All rights reserved.</p>
          </div>
        </div>
      </footer>
    </div>
  );
}
