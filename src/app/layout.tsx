import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "DueMate - Invoice Management & Payment Reminders",
  description:
    "Invoice Management & Payment Reminders for Small Businesses. Never miss a payment deadline again!",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="antialiased">{children}</body>
    </html>
  );
}
