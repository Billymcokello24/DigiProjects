<script setup>
import { ref, onMounted } from 'vue'
import api from '@/api/axios'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import StatusBadge from '@/components/ui/StatusBadge.vue'
import jsPDF from 'jspdf'
import autoTable from 'jspdf-autotable'
import ictaLogo from '@/assets/icta-logo.png'

const countiesReports = ref([])
const isLoading = ref(false)
const errorMessage = ref('')
const expandedCounties = ref(new Set())
const isExportingPDF = ref(false)

const fetchCountyReports = async () => {
  isLoading.value = true
  errorMessage.value = ''
  try {
    const response = await api.get('/submissions/county-reports')
    countiesReports.value = response.data
  } catch (err) {
    if (err.response?.status === 403) {
      errorMessage.value = 'You do not have permission to view county reports'
    } else {
      errorMessage.value = 'Failed to load county reports'
    }
    console.error(err)
  } finally {
    isLoading.value = false
  }
}

const toggleExpanded = (countyId) => {
  if (expandedCounties.value.has(countyId)) {
    expandedCounties.value.delete(countyId)
  } else {
    expandedCounties.value.add(countyId)
  }
}

const isExpanded = (countyId) => {
  return expandedCounties.value.has(countyId)
}

const getStatusColor = (status) => {
  const statusMap = {
    'UP': 'success',
    'DOWN': 'danger',
    'Stable': 'info',
    'Maintenance': 'warning',
  }
  return statusMap[status] || 'neutral'
}

const formatDate = (date) => {
  return new Date(date).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  })
}

const generateCombinedPDF = async () => {
  if (countiesReports.value.length === 0) {
    alert('No reports to export')
    return
  }

  isExportingPDF.value = true
  try {
    const doc = new jsPDF('p', 'mm', 'a4')
    const pageHeight = doc.internal.pageSize.height
    const pageWidth = doc.internal.pageSize.width
    const margin = 15
    const contentWidth = pageWidth - 2 * margin

    // Nyanza-style color scheme
    const colors = {
      black: [0, 0, 0],
      darkGray: [50, 50, 50],
      gray: [100, 100, 100],
      lightGray: [230, 230, 230],
      veryLightGray: [245, 245, 245],
      white: [255, 255, 255]
    }

    const addPageHeader = (pageNum) => {
      doc.setPage(pageNum)
      
      // Light gray header background
      doc.setFillColor(245, 245, 245)
      doc.rect(0, 0, pageWidth, 32, 'F')
      
      // Organization name - left side, bold and larger
      doc.setFont('helvetica', 'bold')
      doc.setFontSize(11)
      doc.setTextColor(colors.black[0], colors.black[1], colors.black[2])
      doc.text('ICT AUTHORITY', margin, 7)
      
      // Report title - left side (removed)
      
      // Contact info - left side, smaller
      doc.setFont('helvetica', 'normal')
      doc.setFontSize(7)
      doc.setTextColor(colors.gray[0], colors.gray[1], colors.gray[2])
      doc.text('Teleposta Towers, 12th Floor, Kenyatta Avenue', margin, 10)
      doc.text('PO Box 27150-00100, Nairobi, Kenya | Tel: +254 20 2089061 | www.icta.go.ke', margin, 13)
      
      // Logo on the extreme right
      try {
        if (ictaLogo) {
          doc.addImage(ictaLogo, 'PNG', pageWidth - margin - 22, 2, 22, 22)
        }
      } catch (e) {
        // Silent fail
      }
      
      // Bottom border line
      doc.setDrawColor(0, 0, 0)
      doc.setLineWidth(0.5)
      doc.line(0, 32, pageWidth, 32)
    }

    const addPageFooter = (pageNum, totalPages) => {
      doc.setPage(pageNum)
      
      // Footer line
      doc.setDrawColor(0, 0, 0)
      doc.setLineWidth(0.5)
      doc.line(margin, pageHeight - 12, pageWidth - margin, pageHeight - 12)
      
      // Footer text
      doc.setFont('helvetica', 'normal')
      doc.setFontSize(8)
      doc.setTextColor(colors.gray[0], colors.gray[1], colors.gray[2])
      doc.text(`Page ${pageNum} of ${totalPages}`, margin, pageHeight - 8)
      doc.text(`Generated: ${new Date().toLocaleDateString('en-US')}`, pageWidth / 2 - 30, pageHeight - 8)
      doc.text(`ICT Authority`, pageWidth - margin - 40, pageHeight - 8, { align: 'right' })
    }

    // ===== COVER PAGE =====
    doc.setFillColor(255, 255, 255)
    doc.rect(0, 0, pageWidth, pageHeight, 'F')
    addPageHeader(1)
    
    let y = 50
    
    // Main title - no borders
    doc.setFont('helvetica', 'bold')
    doc.setFontSize(22)
    doc.setTextColor(colors.black[0], colors.black[1], colors.black[2])
    doc.text('STATUS OF NATIONAL ICT PROJECTS', pageWidth / 2, y, { align: 'center' })
    
    y += 15
    
    // Subtitle - no borders
    doc.setFont('helvetica', 'bold')
    doc.setFontSize(14)
    doc.setTextColor(colors.darkGray[0], colors.darkGray[1], colors.darkGray[2])
    doc.text('COUNTIES COMPREHENSIVE REPORT', pageWidth / 2, y, { align: 'center' })
    
    y += 20
    
    // Stats box - simple box, no fancy styling
    doc.setDrawColor(0, 0, 0)
    doc.setLineWidth(0.5)
    doc.rect(margin + 10, y, contentWidth - 20, 28)
    
    const totalSubs = countiesReports.value.reduce((sum, c) => sum + c.report.total_submissions, 0)
    const totalProj = countiesReports.value.reduce((sum, c) => sum + c.report.total_projects, 0)
    const activeCounties = countiesReports.value.filter(c => c.county.is_active).length
    
    doc.setFont('helvetica', 'bold')
    doc.setFontSize(9)
    doc.setTextColor(colors.black[0], colors.black[1], colors.black[2])
    doc.text(`Total Counties: ${countiesReports.value.length}  |  Total Submissions: ${totalSubs}  |  Total Projects: ${totalProj}`, pageWidth / 2, y + 7, { align: 'center' })
    doc.text(`Active Counties: ${activeCounties}  |  Report Period: July 2024 - August 2025`, pageWidth / 2, y + 15, { align: 'center' })
    
    y += 40
    
    // Date and time
    doc.setFont('helvetica', 'normal')
    doc.setFontSize(9)
    doc.setTextColor(colors.darkGray[0], colors.darkGray[1], colors.darkGray[2])
    doc.text(`Generated: ${new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })} | ${new Date().toLocaleTimeString('en-US')}`, pageWidth / 2, y, { align: 'center' })
    
    y += 15
    
    // Executive summary section - simple box
    doc.setFillColor(230, 230, 230)
    doc.rect(margin + 5, y, contentWidth - 10, 40, 'F')
    doc.setDrawColor(0, 0, 0)
    doc.setLineWidth(0.5)
    doc.rect(margin + 5, y, contentWidth - 10, 40)
    
    doc.setFont('helvetica', 'bold')
    doc.setFontSize(9)
    doc.setTextColor(colors.black[0], colors.black[1], colors.black[2])
    doc.text('EXECUTIVE SUMMARY', margin + 8, y + 4)
    
    doc.setFont('helvetica', 'normal')
    doc.setFontSize(8)
    doc.setTextColor(colors.darkGray[0], colors.darkGray[1], colors.darkGray[2])
    const summaryText = `This comprehensive report presents the status of all ICT Authority projects across Kenya's ${countiesReports.value.length} counties. The report consolidates submission data from county offices, detailing project phases, implementation status, and officer remarks. A total of ${totalSubs} submissions covering ${totalProj} distinct projects have been aggregated.`
    const splitSummary = doc.splitTextToSize(summaryText, contentWidth - 20)
    doc.text(splitSummary, margin + 8, y + 10)
    
    // ===== TABLE OF CONTENTS =====
    doc.addPage()
    const tocPageNum = doc.internal.getNumberOfPages()
    addPageHeader(tocPageNum)
    
    y = 38
    doc.setFont('helvetica', 'bold')
    doc.setFontSize(12)
    doc.setTextColor(colors.black[0], colors.black[1], colors.black[2])
    doc.text('TABLE OF CONTENTS', margin, y)
    
    y += 8
    
    doc.setFont('helvetica', 'normal')
    doc.setFontSize(9)
    doc.setTextColor(colors.black[0], colors.black[1], colors.black[2])
    
    // First pass: render TOC items and calculate actual page numbers
    let currentTocY = y
    let tocPageCounter = 3 // Start after cover (page 1) and TOC (page 2)
    const countyPageNumbers = []
    
    countiesReports.value.forEach((county, idx) => {
      if (currentTocY > pageHeight - 25) {
        doc.addPage()
        addPageHeader(doc.internal.getNumberOfPages())
        currentTocY = 38
      }
      
      countyPageNumbers.push(tocPageCounter)
      
      // Write TOC entry with page number
      const tocText = `${idx + 1}. ${county.county.name} (${county.county.region})`
      const pageNumberText = `${tocPageCounter}`
      
      // Write the county name with link
      doc.textWithLink(tocText, margin + 5, currentTocY, { pageNumber: tocPageCounter })
      
      // Write page number right-aligned
      doc.text(pageNumberText, pageWidth - margin - 5, currentTocY, { align: 'right' })
      
      currentTocY += 5
      tocPageCounter += 1 // Increment by 1 per county page
    })

    // ===== COUNTY REPORTS =====
    for (let i = 0; i < countiesReports.value.length; i++) {
      const countyReport = countiesReports.value[i]
      
      doc.addPage()
      const pageNum = doc.internal.getNumberOfPages()
      addPageHeader(pageNum)
      
      let currentY = 38
      
      // County title
      doc.setFont('helvetica', 'bold')
      doc.setFontSize(12)
      doc.setTextColor(colors.black[0], colors.black[1], colors.black[2])
      doc.text(`${i + 1}. ${countyReport.county.name}`, margin, currentY)
      
      currentY += 8
      
      // County info box
      doc.setFillColor(245, 245, 245)
      doc.rect(margin, currentY, contentWidth, 14, 'F')
      doc.setDrawColor(180, 180, 180)
      doc.setLineWidth(0.5)
      doc.rect(margin, currentY, contentWidth, 14)
      
      doc.setFont('helvetica', 'normal')
      doc.setFontSize(8)
      doc.setTextColor(colors.darkGray[0], colors.darkGray[1], colors.darkGray[2])
      doc.text(`Region: ${countyReport.county.region}  |  Officers: ${countyReport.county.officers_count}  |  Total Submissions: ${countyReport.report.total_submissions}  |  Status: ${countyReport.county.is_active ? 'ACTIVE' : 'INACTIVE'}`, margin + 3, currentY + 4)
      doc.text(`Total Projects: ${countyReport.report.total_projects}`, margin + 3, currentY + 8)
      
      currentY += 18
      
      // Submissions table
      if (countyReport.report.submissions && countyReport.report.submissions.length > 0) {
        const tableData = countyReport.report.submissions.map((s) => [
          s.phase || 'N/A',
          s.site || 'N/A',
          s.project_type || 'N/A',
          s.status || 'UP',
          s.remarks ? s.remarks.substring(0, 20) + (s.remarks.length > 20 ? '...' : '') : '-'
        ])
        
        autoTable(doc, {
          startY: currentY,
          head: [['Phase', 'Site', 'Project Type', 'Status', 'Remarks']],
          body: tableData,
          theme: 'grid',
          margin: { left: margin, right: margin },
          headStyles: {
            fillColor: [0, 0, 0],
            textColor: [255, 255, 255],
            fontStyle: 'bold',
            fontSize: 8,
            cellPadding: 2.5,
            font: 'helvetica'
          },
          bodyStyles: {
            textColor: colors.darkGray,
            fontSize: 7,
            cellPadding: 2,
            font: 'helvetica'
          },
          alternateRowStyles: {
            fillColor: [245, 245, 245]
          },
          columnStyles: {
            0: { cellWidth: 20 },
            1: { cellWidth: 30 },
            2: { cellWidth: 28 },
            3: { cellWidth: 18 },
            4: { cellWidth: 44 }
          }
        })
        
        currentY = doc.lastAutoTable.finalY + 6
      } else {
        doc.setFont('helvetica', 'italic')
        doc.setFontSize(8)
        doc.setTextColor(150, 150, 150)
        doc.text('No submissions recorded for this county', margin + 3, currentY)
        currentY += 6
      }
      
      // Remarks section
      const remarksData = countyReport.report.submissions.filter(s => s.remarks && s.remarks.length > 0)
      if (remarksData.length > 0) {
        if (currentY > pageHeight - 40) {
          doc.addPage()
          addPageHeader(doc.internal.getNumberOfPages())
          currentY = 35
        }
        
        currentY += 3
        doc.setFont('helvetica', 'bold')
        doc.setFontSize(9)
        doc.setTextColor(colors.black[0], colors.black[1], colors.black[2])
        doc.text('PROJECT REMARKS', margin, currentY)
        currentY += 6
        
        doc.setFont('helvetica', 'normal')
        doc.setFontSize(7.5)
        doc.setTextColor(colors.darkGray[0], colors.darkGray[1], colors.darkGray[2])
        
        remarksData.forEach((submission) => {
          if (currentY > pageHeight - 20) {
            doc.addPage()
            addPageHeader(doc.internal.getNumberOfPages())
            currentY = 35
          }
          
          const remarkText = `${submission.site}: ${submission.remarks}`
          const splitRemark = doc.splitTextToSize(remarkText, contentWidth - 5)
          doc.text(splitRemark, margin + 3, currentY)
          currentY += splitRemark.length * 3.5 + 2
        })
      }
    }

    // Add footers to all pages
    const totalPages = doc.internal.getNumberOfPages()
    for (let i = 1; i <= totalPages; i++) {
      addPageFooter(i, totalPages)
    }

    // Save
    doc.save(`National_ICT_Projects_Report_${new Date().getTime()}.pdf`)
  } catch (error) {
    console.error('PDF Generation Error:', error)
    alert('Failed to generate PDF. Please try again.')
  } finally {
    isExportingPDF.value = false
  }
}

onMounted(() => {
  fetchCountyReports()
})
</script>

<template>
  <div class="county-reports-view">
    <!-- Error Message -->
    <div v-if="errorMessage" class="alert alert-error">
      {{ errorMessage }}
    </div>

    <!-- Header -->
    <div class="reports-header">
      <div>
        <h1 class="page-title">County Reports</h1>
        <p class="page-subtitle">Aggregated submissions by county</p>
      </div>
      <div class="header-actions">
        <BaseButton variant="outline" @click="fetchCountyReports" :disabled="isLoading">
          🔄 Refresh
        </BaseButton>
        <BaseButton variant="primary" @click="generateCombinedPDF" :disabled="isLoading || isExportingPDF || countiesReports.length === 0">
          {{ isExportingPDF ? '⏳ Generating PDF...' : '📥 Download PDF' }}
        </BaseButton>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="isLoading" class="loading-state">
      <div class="spinner"></div>
      Loading county reports...
    </div>

    <!-- Empty State -->
    <div v-else-if="countiesReports.length === 0" class="empty-state">
      <p>No counties or submissions found yet.</p>
    </div>

    <!-- Counties Reports -->
    <div v-else class="counties-reports-container">
      <div v-for="(countyReport, index) in countiesReports" :key="countyReport.county.id" class="county-section">
        <!-- County Card Header -->
        <BaseCard class="county-card" :class="{ expanded: isExpanded(countyReport.county.id) }">
          <div class="county-header" @click="toggleExpanded(countyReport.county.id)">
            <div class="county-info">
              <span class="expand-icon">{{ isExpanded(countyReport.county.id) ? '▼' : '▶' }}</span>
              <div class="county-title">
                <h2 class="county-name">{{ index + 1 }}. {{ countyReport.county.name }}</h2>
                <p class="county-meta">
                  Region: {{ countyReport.county.region }} | Officers: {{ countyReport.county.officers_count }}
                </p>
              </div>
            </div>

            <div class="county-stats">
              <div class="stat">
                <span class="stat-label">Submissions</span>
                <span class="stat-value">{{ countyReport.report.total_submissions }}</span>
              </div>
              <div class="stat">
                <span class="stat-label">Projects</span>
                <span class="stat-value">{{ countyReport.report.total_projects }}</span>
              </div>
              <StatusBadge :status="countyReport.county.is_active ? 'success' : 'neutral'">
                {{ countyReport.county.is_active ? 'Active' : 'Inactive' }}
              </StatusBadge>
            </div>
          </div>

          <!-- Report Details (Expandable) -->
          <div v-if="isExpanded(countyReport.county.id)" class="county-report">
            <!-- Status Summary -->
            <div class="report-section">
              <h3>Status Summary</h3>
              <div class="status-grid">
                <div v-for="(count, status) in countyReport.report.statuses" :key="status" class="status-item">
                  <StatusBadge :status="getStatusColor(status)">
                    {{ status }}: {{ count }}
                  </StatusBadge>
                </div>
              </div>
            </div>

            <!-- Submissions Table -->
            <div class="report-section">
              <h3>Submissions ({{ countyReport.report.submissions.length }})</h3>
              <div v-if="countyReport.report.submissions.length === 0" class="empty-submissions">
                No submissions for this county yet.
              </div>
              <div v-else class="submissions-table">
                <table>
                  <thead>
                    <tr>
                      <th>Project Type</th>
                      <th>Phase</th>
                      <th>Site</th>
                      <th>Status</th>
                      <th>Officer</th>
                      <th>Submitted</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="submission in countyReport.report.submissions" :key="submission.id">
                      <td class="font-bold">{{ submission.project_type }}</td>
                      <td>{{ submission.phase }}</td>
                      <td>{{ submission.site }}</td>
                      <td>
                        <StatusBadge :status="getStatusColor(submission.status)">
                          {{ submission.status }}
                        </StatusBadge>
                      </td>
                      <td>{{ submission.officer_name }}</td>
                      <td class="text-sm">{{ formatDate(submission.created_at) }}</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>

            <!-- Remarks -->
            <div v-if="countyReport.report.submissions.some(s => s.remarks)" class="report-section">
              <h3>Remarks</h3>
              <div class="remarks-list">
                <div v-for="submission in countyReport.report.submissions.filter(s => s.remarks)" :key="submission.id" class="remark-item">
                  <p class="remark-title">{{ submission.site }} ({{ submission.officer_name }})</p>
                  <p class="remark-text">{{ submission.remarks }}</p>
                </div>
              </div>
            </div>
          </div>
        </BaseCard>
      </div>
    </div>
  </div>
</template>

<style scoped>
.county-reports-view {
  padding: 2rem;
}

.alert {
  padding: 1rem;
  border-radius: 0.5rem;
  margin-bottom: 1rem;
}

.alert-error {
  background-color: #fee2e2;
  color: #991b1b;
  border: 1px solid #fca5a5;
}

.reports-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.header-actions {
  display: flex;
  gap: 1rem;
}

.page-title {
  font-size: 2rem;
  font-weight: 700;
  color: #1f2937;
  margin: 0;
}

.page-subtitle {
  color: #6b7280;
  margin: 0.5rem 0 0 0;
}

.loading-state {
  text-align: center;
  padding: 3rem 2rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
  color: #666;
}

.spinner {
  width: 2rem;
  height: 2rem;
  border: 3px solid #e5e7eb;
  border-top-color: #3b82f6;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.empty-state {
  padding: 2rem;
  text-align: center;
  color: #666;
}

.counties-reports-container {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.county-section {
  animation: slideIn 0.3s ease-out;
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.county-card {
  cursor: pointer;
  transition: all 0.2s;
}

.county-card:hover {
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
}

.county-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
}

.county-info {
  display: flex;
  align-items: center;
  gap: 1rem;
  flex: 1;
}

.expand-icon {
  font-size: 0.75rem;
  color: #6b7280;
  transition: transform 0.2s;
}

.county-title {
  flex: 1;
}

.county-name {
  font-size: 1.25rem;
  font-weight: 600;
  color: #1f2937;
  margin: 0;
}

.county-meta {
  font-size: 0.875rem;
  color: #6b7280;
  margin: 0.25rem 0 0 0;
}

.county-stats {
  display: flex;
  align-items: center;
  gap: 2rem;
}

.stat {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.25rem;
}

.stat-label {
  font-size: 0.75rem;
  color: #6b7280;
  text-transform: uppercase;
  font-weight: 500;
}

.stat-value {
  font-size: 1.5rem;
  font-weight: 700;
  color: #1f2937;
}

.county-report {
  padding: 0 1.5rem 1.5rem 1.5rem;
  border-top: 1px solid #e5e7eb;
}

.report-section {
  margin-bottom: 2rem;
}

.report-section h3 {
  font-size: 1rem;
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 1rem;
}

.status-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 1rem;
}

.status-item {
  display: flex;
  align-items: center;
}

.empty-submissions {
  padding: 1rem;
  text-align: center;
  color: #999;
  background-color: #f9fafb;
  border-radius: 0.4rem;
}

.submissions-table {
  overflow-x: auto;
}

.submissions-table table {
  width: 100%;
  border-collapse: collapse;
}

.submissions-table thead {
  background-color: #f3f4f6;
}

.submissions-table th {
  padding: 0.75rem;
  text-align: left;
  font-weight: 600;
  color: #1f2937;
  border-bottom: 2px solid #e5e7eb;
}

.submissions-table td {
  padding: 0.75rem;
  border-bottom: 1px solid #e5e7eb;
}

.submissions-table tbody tr:hover {
  background-color: #f9fafb;
}

.font-bold {
  font-weight: 600;
}

.text-sm {
  font-size: 0.875rem;
  color: #6b7280;
}

.remarks-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.remark-item {
  padding: 1rem;
  background-color: #f9fafb;
  border-radius: 0.4rem;
  border-left: 3px solid #3b82f6;
}

.remark-title {
  font-weight: 600;
  color: #1f2937;
  margin: 0 0 0.5rem 0;
}

.remark-text {
  color: #6b7280;
  margin: 0;
  white-space: pre-wrap;
}

/* Mobile Responsive Styles */
@media (max-width: 768px) {
  .county-reports-view {
    padding: 1rem;
  }

  .reports-header {
    flex-direction: column;
    gap: 1rem;
    align-items: flex-start;
  }

  .header-actions {
    width: 100%;
    flex-direction: column;
  }

  .header-actions button {
    width: 100%;
  }

  .page-title {
    font-size: 1.5rem;
  }

  .county-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 1rem;
    padding: 1rem;
  }

  .county-info {
    width: 100%;
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }

  .county-title {
    width: 100%;
  }

  .county-name {
    font-size: 1rem;
  }

  .county-stats {
    width: 100%;
    gap: 1rem;
    flex-wrap: wrap;
  }

  .stat {
    flex: 1;
    min-width: 120px;
  }

  .county-report {
    padding: 1rem;
  }

  .report-section {
    margin-bottom: 1.5rem;
  }

  .status-grid {
    grid-template-columns: 1fr;
    gap: 0.75rem;
  }

  .status-item {
    width: 100%;
  }

  .submissions-table {
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
  }

  .submissions-table table {
    min-width: 600px;
    font-size: 0.875rem;
  }

  .submissions-table th,
  .submissions-table td {
    padding: 0.5rem;
  }

  .remarks-list {
    gap: 0.75rem;
  }

  .remark-item {
    padding: 0.75rem;
  }

  .remark-title {
    font-size: 0.875rem;
  }

  .remark-text {
    font-size: 0.8rem;
  }
}

@media (max-width: 480px) {
  .county-reports-view {
    padding: 0.75rem;
  }

  .page-title {
    font-size: 1.25rem;
  }

  .header-actions {
    width: 100%;
  }

  .county-name {
    font-size: 0.9rem;
  }

  .county-meta {
    font-size: 0.75rem;
  }

  .stat-label {
    font-size: 0.65rem;
  }

  .stat-value {
    font-size: 1.25rem;
  }

  .submissions-table table {
    min-width: 500px;
    font-size: 0.75rem;
  }

  .submissions-table th,
  .submissions-table td {
    padding: 0.4rem;
  }
}
</style>
