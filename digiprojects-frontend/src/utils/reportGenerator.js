import jsPDF from 'jspdf'
import autoTable from 'jspdf-autotable'

export const generateProfessionalReport = (data, user, logo = null) => {
    try {
        const doc = new jsPDF()
        const countyName = (user?.county || 'Nairobi').toUpperCase()

        // Header Config
        const margin = 15
        const colorPrimary = [0, 0, 0] // Black
        const colorSecondary = [187, 0, 0] // Kenya Red

        // 1. HEADER (Top Left)
        doc.setFont('helvetica', 'normal')
        doc.setFontSize(10)
        doc.setTextColor(colorPrimary[0], colorPrimary[1], colorPrimary[2])
        doc.text('ICT Authority', margin, 20)
        doc.text('Teleposta Towers 12th Floor, Kenyatta Ave', margin, 25)
        doc.text('PO Box 27150 - 00100 Nairobi Kenya', margin, 30)
        doc.text('Tel: +254 20 2089061', margin, 35)
        doc.text('www.icta.go.ke', margin, 40)

        // 2. LOGO (Top Right)
        if (logo) {
            try {
                // logo is now a PNG
                doc.addImage(logo, 'PNG', 155, 15, 40, 22)
            } catch (e) {
                console.warn('Failed to add logo to PDF:', e)
                mockLogoText(doc, colorSecondary, colorPrimary)
            }
        } else {
            mockLogoText(doc, colorSecondary, colorPrimary)
        }

        // 3. TITLE (Centered)
        doc.setDrawColor(200, 200, 200)
        doc.line(margin, 45, 195, 45) // Separator

        doc.setFontSize(18)
        doc.setTextColor(colorPrimary[0], colorPrimary[1], colorPrimary[2])
        doc.text('STATUS OF NATIONAL ICT PROJECTS', 105, 70, { align: 'center' })

        doc.setFontSize(22)
        doc.text(`${countyName} COUNTY`, 105, 85, { align: 'center' })

        doc.setFontSize(11)
        doc.setFont('helvetica', 'normal')
        doc.text(`Reporting Period: July 2024 - August 2025`, 105, 100, { align: 'center' })

        // 4. DATA TABLE
        const tableRows = data.map((s) => [
            s.phase || 'N/A',
            s.site || s.project || 'N/A',
            s.status?.toUpperCase() || 'UP',
            s.remarks || 'Stable'
        ])

        autoTable(doc, {
            startY: 120,
            head: [['Phase', 'Site / Project', 'Status', 'Issue / Remarks']],
            body: tableRows,
            theme: 'grid',
            headStyles: {
                fillColor: [245, 245, 245],
                textColor: [0, 0, 0],
                fontStyle: 'bold',
                lineColor: [200, 200, 200],
                lineWidth: 0.1
            },
            styles: {
                cellPadding: 5,
                fontSize: 9,
                lineColor: [200, 200, 200],
                lineWidth: 0.1
            },
            columnStyles: {
                0: { cellWidth: 25 },
                2: { cellWidth: 30, fontStyle: 'bold' }
            }
        })

        // 5. FOOTER (Page Numbers)
        const pageCount = doc.internal.getNumberOfPages()
        for (let i = 1; i <= pageCount; i++) {
            doc.setPage(i)
            doc.setFontSize(10)
            doc.setTextColor(150, 150, 150)
            doc.text(`${i} | Page`, 195, 285, { align: 'right' })
        }

        // SAVE
        doc.save(`ICTA_Status_Report_${countyName.replace(/\s+/g, '_')}.pdf`)
    } catch (error) {
        console.error('PDF Generation Error:', error)
        alert('Failed to generate PDF. Please try again or use the Excel format.')
    }
}

const mockLogoText = (doc, colorSecondary, colorPrimary) => {
    doc.setFont('helvetica', 'bold')
    doc.setFontSize(24)
    doc.setTextColor(colorSecondary[0], colorSecondary[1], colorSecondary[2])
    doc.text('ICT', 160, 25)
    doc.setFontSize(10)
    doc.setTextColor(colorPrimary[0], colorPrimary[1], colorPrimary[2])
    doc.text('Authority', 160, 31)
}
