import type { Metadata } from "next";
import "./globals.css";
export const metadata: Metadata = {title:"XeGhép247",description:"Ghép người, ghép hàng, ghép ghế du lịch"};
export default function RootLayout({children}:{children:React.ReactNode}) {return <html lang="vi"><body>{children}</body></html>;}
